import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Các ngữ cảnh chính của AI Coach V1.
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
      throw StateError('AI Coach requires an authenticated user.');
    }
    return user;
  }

  DocumentReference<Map<String, dynamic>> _conversation(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('aiConversations')
        .doc('main');
  }

  Stream<List<AiMessage>> watchMessages() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(const <AiMessage>[]);
    }

    return _conversation(user.uid)
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
  }) async {
    final user = _requireUser();
    final clean = text.trim();
    if (clean.isEmpty) return;

    final conversation = _conversation(user.uid);

    // Firestore là lịch sử private do chính user sở hữu.
    // Nếu rules chưa deploy, lỗi permission-denied sẽ xuất hiện rõ ở UI.
    final conversationSnapshot = await conversation.get();
    if (conversationSnapshot.exists) {
      await conversation.update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await conversation.set({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await conversation.collection('messages').add({
      'role': 'user',
      'content': clean,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final recent = await conversation
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    final history = recent.docs.reversed.map((doc) {
      final data = doc.data();
      return <String, dynamic>{
        'role': data['role'],
        'content': data['content'],
      };
    }).toList();

    final callable = _functions.httpsCallable('aiCoach');
    final result = await callable.call(<String, dynamic>{
      'message': clean,
      'locale': locale == 'en' ? 'en' : 'vi',
      'mode': mode.name,
      'history': history,
    });

    if (result.data is! Map) {
      throw StateError('AI Coach returned an invalid response.');
    }

    final data = Map<String, dynamic>.from(result.data as Map);
    final reply = (data['reply'] as String? ?? '').trim();
    if (reply.isEmpty) {
      throw StateError('AI Coach returned an empty response.');
    }

    await conversation.collection('messages').add({
      'role': 'assistant',
      'content': reply,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearConversation() async {
    final user = _requireUser();
    final conversation = _conversation(user.uid);
    final messages = await conversation.collection('messages').get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(conversation);
    await batch.commit();
  }
}
