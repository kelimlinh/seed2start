import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ai_launch_context.dart';

/// Các ngữ cảnh chính của Mầm.
enum AiCoachMode { companion, goal, reflection, hero }

class AiMessage {
  const AiMessage({
    required this.role,
    required this.content,
    this.createdAt,
  });

  final String role;
  final String content;
  final DateTime? createdAt;

  factory AiMessage.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AiMessage(
      role: data['role'] == 'assistant' ? 'assistant' : 'user',
      content: (data['content'] as String? ?? '').trim(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class AiService {
  AiService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Mầm requires an authenticated user.');
    }
    return user;
  }

  String _safeThreadPart(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return 'context';

    final cleaned = value.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );

    return cleaned.length <= 70 ? cleaned : cleaned.substring(0, 70);
  }

  String _conversationId(AiLaunchContext? launchContext) {
    if (launchContext?.source == AiLaunchSource.workbookReflection) {
      final resource = _safeThreadPart(launchContext?.resourceId);
      final block = _safeThreadPart(launchContext?.blockId);
      return 'workbook_${resource}_$block';
    }

    // Preserve the existing general conversation and its history.
    return 'main';
  }

  DocumentReference<Map<String, dynamic>> _conversation(
    String uid, {
    AiLaunchContext? launchContext,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('aiConversations')
        .doc(_conversationId(launchContext));
  }

  Stream<List<AiMessage>> watchMessages({
    AiLaunchContext? launchContext,
  }) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(const <AiMessage>[]);
    }

    return _conversation(
      user.uid,
      launchContext: launchContext,
    )
        .collection('messages')
        .orderBy('createdAt')
        .limitToLast(40)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(AiMessage.fromDocument)
              .where((message) => message.content.isNotEmpty)
              .toList(),
        );
  }

  Future<void> send({
    required String text,
    required String locale,
    required AiCoachMode mode,
    AiLaunchContext? launchContext,
  }) async {
    final user = _requireUser();
    final clean = text.trim();
    if (clean.isEmpty) return;

    final conversation = _conversation(
      user.uid,
      launchContext: launchContext,
    );

    // Read previous history BEFORE storing the current message.
    // This prevents the current message from being sent twice to the model.
    final previous = await conversation
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(8)
        .get();

    final history = previous.docs.reversed
        .map((doc) {
          final data = doc.data();
          final role = data['role'];
          final content = data['content'];
          if (role is! String || content is! String) return null;

          return <String, dynamic>{
            'role': role,
            'content': content,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    final conversationSnapshot = await conversation.get();
    final metadata = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'source': launchContext?.source.name ?? 'general',
    };

    if (launchContext?.resourceId?.trim().isNotEmpty == true) {
      metadata['resourceId'] = launchContext!.resourceId!.trim();
    }
    if (launchContext?.blockId?.trim().isNotEmpty == true) {
      metadata['blockId'] = launchContext!.blockId!.trim();
    }

    if (conversationSnapshot.exists) {
      await conversation.update(metadata);
    } else {
      await conversation.set({
        'createdAt': FieldValue.serverTimestamp(),
        ...metadata,
      });
    }

    await conversation.collection('messages').add({
      'role': 'user',
      'content': clean,
      'mode': mode.name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final payload = <String, dynamic>{
      'message': clean,
      'locale': locale == 'en' ? 'en' : 'vi',
      'mode': mode.name,
      'history': history,
    };

    if (launchContext?.isContextual == true) {
      payload['context'] = launchContext!.toRequestMap();
    }

    final callable = _functions.httpsCallable('aiCoach');
    final result = await callable.call(payload);

    if (result.data is! Map) {
      throw StateError('Mầm returned an invalid response.');
    }

    final data = Map<String, dynamic>.from(result.data as Map);
    final reply = (data['reply'] as String? ?? '').trim();
    if (reply.isEmpty) {
      throw StateError('Mầm returned an empty response.');
    }

    await conversation.collection('messages').add({
      'role': 'assistant',
      'content': reply,
      'mode': mode.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearConversation({
    AiLaunchContext? launchContext,
  }) async {
    final user = _requireUser();
    final conversation = _conversation(
      user.uid,
      launchContext: launchContext,
    );
    final messages = await conversation.collection('messages').get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(conversation);
    await batch.commit();
  }
}
