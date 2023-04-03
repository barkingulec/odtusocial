import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/services/cloud/cloud_communities.dart';
import 'package:social/services/cloud/cloud_storage_constants.dart';
import 'package:social/services/cloud/cloud_storage_exceptions.dart';


class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String desc,
  }) async {
    try {
      await notes.doc(documentId).update({descFieldName: desc});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudCommunity>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudCommunity.fromSnapshot(doc)));
    return allNotes;
  }

  Future<CloudCommunity> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      nameFieldName: '',
    });
    final fetchedNote = await document.get();
    return CloudCommunity(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      name: '',
      desc: '',
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}