import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/models/post.dart';
import 'package:social/services/auth/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> addEvent(String communityId, String desc ,String name, String userUid,
      String username, Timestamp date, List _selectedOptions) async {
    String res = "Some error occurred";
    try {
      DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
      var image = (snap.data()! as dynamic)['image'];
      var communityName = (snap.data()! as dynamic)['name'];
      if (desc.isNotEmpty && name.isNotEmpty) {
        String eventId = const Uuid().v1();
        _firestore
            .collection('communities')
            .doc(communityId)
            .collection('events')
            .doc(eventId)
            .set({
          'added_by': username,
          'name': name,
          'uid': userUid,
          'desc': desc,
          'eventId': eventId,
          'datePublished': DateTime.now(),
          'date': date,
          'image': image,
          'for_whom': _selectedOptions,
          'community_name': communityName,
          'communityId': communityId,
          'edited_on': "",
          'edited_by': "",
        });
        res = 'success';

        var admins = (snap.data()! as dynamic)['admins'];
        var members = (snap.data()! as dynamic)['enrolledUsers'];

        if (_selectedOptions[1] == true) {
          for(var memberUid in members) {
            await _firestore.collection('profiles').doc(memberUid).update({
                'notifications': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
                'notifications_new': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
        });
          }
        }
        else if (_selectedOptions[0] == true) {
          for(var adminUid in admins) {
            await _firestore.collection('profiles').doc(adminUid).update({
                'notifications': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
                'notifications_new': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
        });
          }
        }

      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deleteEvent(String communityId, String eventId) async {
    String res = "Some error occurred";
    try {

      await _firestore.collection('communities').doc(communityId).collection("events").doc(eventId).delete();

      CollectionReference _collectionRef = _firestore.collection('profiles');
      QuerySnapshot querySnapshot = await _collectionRef.get();
      final allData = querySnapshot.docs.map((doc) => doc.data()! as dynamic).toList();
      for (var data in allData) {
        if(data['notifications'].isNotEmpty) {
          for (var notification in data['notifications']) {
            if(notification['eventId'] == eventId){
              await _firestore.collection('profiles').doc(data['uid']).update({
                'notifications': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
        });
            }
          }
        }
        if(data['notifications_new'].isNotEmpty) {
          for (var notification in data['notifications_new']) {
            if(notification['eventId'] == eventId){
              await _firestore.collection('profiles').doc(data['uid']).update({
                'notifications_new': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
        });
            }
          }
        }
      }

      res = 'Event is successfully deleted.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> enrollCommunity(
    String uid,
    String communityId
  ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('profiles').doc(uid).get();
      List enrolledCom = (snap.data()! as dynamic)['enrolledCom'];

      if(enrolledCom.contains(communityId)) {
        await _firestore.collection('communities').doc(communityId).update({
          'requests': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'requestedCom': FieldValue.arrayRemove([communityId])
        });
      } else {
        await _firestore.collection('communities').doc(communityId).update({
          'requests': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'requestedCom': FieldValue.arrayUnion([communityId])
        });
      }

    } catch(e) {
      print(e.toString());
    }
  }

  Future<void> acceptRequest(
    String uid,
    String communityId
  ) async {
    try {
        await _firestore.collection('communities').doc(communityId).update({
          'enrolledUsers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'enrolledCom': FieldValue.arrayUnion([communityId])
        });
        await _firestore.collection('communities').doc(communityId).update({
          'requests': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'requestedCom': FieldValue.arrayRemove([communityId])
        });
    } catch(e) {
      print(e.toString());
    }
  }

  Future<void> declineRequest(
    String uid,
    String communityId
  ) async {
    try {
        await _firestore.collection('communities').doc(communityId).update({
          'requests': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'requestedCom': FieldValue.arrayRemove([communityId])
        });
    } catch(e) {
      print(e.toString());
    }
  }

  Future<void> leaveCommunity(
    String uid,
    String communityId
  ) async {
    try {
        await _firestore.collection('communities').doc(communityId).update({
          'enrolledUsers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'enrolledCom': FieldValue.arrayRemove([communityId])
        });
    } catch(e) {
      print(e.toString());
    }
  }

Future<void> bookmarkCommunity(
    String uid,
    String communityId
  ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('profiles').doc(uid).get();
      List bookmarkedCom = (snap.data()! as dynamic)['bookmarkedCom'];

      if(bookmarkedCom.contains(communityId)) {
        await _firestore.collection('communities').doc(communityId).update({
          'bookmarkedUsers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'bookmarkedCom': FieldValue.arrayRemove([communityId])
        });
      } else {
        await _firestore.collection('communities').doc(communityId).update({
          'bookmarkedUsers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'bookmarkedCom': FieldValue.arrayUnion([communityId])
        });
      }

    } catch(e) {
      print(e.toString());
    }
  }

  Future<String> updateNotifications(String userId) async {
    String res = "Some error occurred during opening the notifications.";
    try {
      _firestore
            .collection('profiles')
            .doc(userId)
            .update({
          'notifications_new': [],
        });
      res = 'Notification box is opened.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

}