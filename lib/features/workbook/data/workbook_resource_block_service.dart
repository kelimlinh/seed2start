import 'package:cloud_firestore/cloud_firestore.dart';

import 'workbook_models.dart';

class WorkbookResourceBlockService {
  WorkbookResourceBlockService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<WorkbookResourceBlock>> watchBlocks(String resourceId) {
    return _firestore
        .collection('resources')
        .doc(resourceId)
        .collection('blocks')
        .snapshots()
        .map((snapshot) {
      final blocks = snapshot.docs
          .map(
            (doc) => WorkbookResourceBlock.fromFirestore(
              doc.id,
              doc.data(),
            ),
          )
          .where((block) => block.enabled)
          .toList(growable: false);
      blocks.sort((a, b) => a.order.compareTo(b.order));
      return blocks;
    });
  }
}
