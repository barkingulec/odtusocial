import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'cloud_storage_constants.dart';

@immutable
class CloudCommunity {
  final String documentId;
  final String name;
  final String desc;
  final String ownerUserId;

  const CloudCommunity({
    required this.documentId,
    required this.ownerUserId,
    required this.name,
    required this.desc,
  });

  CloudCommunity.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        name = snapshot.data()[nameFieldName] as String,
        desc = snapshot.data()[descFieldName] as String;
}