import 'dart:math';
import 'dart:typed_data';
import 'package:social/models/contact.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/models/post.dart';
import 'package:social/services/auth/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<String> uploadPost(String description, Uint8List file, String uid,
  //     String username, String profImage) async {
  //   // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
  //   String res = "Some error occurred";
  //   try {
  //     String photoUrl =
  //         await StorageMethods().uploadImageToStorage('posts', file, true);
  //     String postId = const Uuid().v1(); // creates unique id based on time
  //     Post post = Post(
  //       description: description,
  //       uid: uid,
  //       username: username,
  //       likes: [],
  //       postId: postId,
  //       datePublished: DateTime.now(),
  //       postUrl: photoUrl,
  //       profImage: profImage,
  //     );
  //     _firestore.collection('posts').doc(postId).set(post.toJson());
  //     res = "success";
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  Future<String> addEvent(String communityId, String desc ,String name, String userUid,
      String username, Timestamp date, List _selectedOptions, String photoUrl, Timestamp endDate, 
      bool isOnline, GeoPoint location, String eventLink, String attendanceType) async {
    String res = "Some error occurred";
    int code = 1000 + Random().nextInt(9000);
    try {
      DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
      //var image = (snap.data()! as dynamic)['image'];
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
          'username': name,  // for search view
          'uid': userUid,
          'desc': desc,
          'eventId': eventId,
          'datePublished': DateTime.now(),
          'date': date,
          'image': photoUrl,
          'photoUrl': photoUrl,  // for search view
          'for_whom': _selectedOptions,
          'community_name': communityName,
          'community_image': photoUrl,
          'communityId': communityId,
          'edited_on': "",
          'edited_by': "",
          'commentsCounter': 0,
          'type': "Event",
          'endDate': endDate,
          'isOnline': isOnline,
          'location': location,
          'eventLink': eventLink,
          'attendanceType': attendanceType,
          'code': code,
          'attendedUsers': [],
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

      QuerySnapshot snap = await _firestore.collection('communities').doc(communityId).collection('events').doc(eventId).collection('comments').get();
      final allComments = snap.docs.map((doc) => doc.data()! as dynamic).toList();

      for (var comment in allComments) {    
        await _firestore.collection('profiles').doc(comment['userId']).update({
              'comments': FieldValue.arrayRemove([{"communityId": communityId, "eventId": eventId, "commentId": comment['commentId'], "comment": comment['comment']}]),
          });
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


        DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
        String communityName = (snap.data()! as dynamic)['name'];
        var communityPhotoUrl = (snap.data()! as dynamic)['photoUrl'];
        var communityGroupId = (snap.data()! as dynamic)['groups']['members'];

        await _firestore.collection('profiles').doc(uid).update({
          'enrolledComData': FieldValue.arrayUnion([{
            communityId: {
              "communityName": communityName,
              "joinDate": DateTime.now(),
              "role": "Member",
              }
            }])
        });


        DocumentSnapshot snap2 = await _firestore.collection('profiles').doc(uid).get();
          var senderUsername = (snap2.data()! as dynamic)['username'];
          var senderPhotoUrl = (snap2.data()! as dynamic)['photoUrl'];

        final refUsers = _firestore.collection('profiles');
        await refUsers
            .doc(uid)
            .collection("messagesCommunities")
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "$senderUsername joined to $communityName",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': uid,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'communityPhotoUrl': communityPhotoUrl,
              'communityName': communityName,
              'photoUrl': communityPhotoUrl,
              'username': communityName,
              'uid': communityId,
              });

        await refUsers
            .doc(uid)
            .collection("messagesCommunities")
            .doc(communityId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "$senderUsername joined to $communityName",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': uid,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'communityPhotoUrl': communityPhotoUrl,
              'communityName': communityName,
              'photoUrl': communityPhotoUrl,
              'username': communityName,
              'uid': communityId,
              });

        final refCommunities = FirebaseFirestore.instance.collection('communities');
        await refCommunities
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .update({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "$senderUsername joined to $communityName",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': uid,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'communityPhotoUrl': communityPhotoUrl,
              'communityName': communityName,
              'photoUrl': communityPhotoUrl,
              'username': communityName,
              'uid': communityId,
              'members': FieldValue.arrayUnion([uid]),
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

  Future<String> leaveCommunity(
    String uid,
    String communityId
  ) async {
    String res = "Some error occurred";
    try {
      DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
      List admins = (snap.data()! as dynamic)['admins'];
      List roles = (snap.data()! as dynamic)['roles'];
      String role = "";
      for (var hs in roles) {
        if (hs.containsKey(uid)) {
          role = hs[uid];
        }
      }

        await _firestore.collection('communities').doc(communityId).update({
          'enrolledUsers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'enrolledCom': FieldValue.arrayRemove([communityId])
        });

        if(admins.contains(uid)) {
        await _firestore.collection('communities').doc(communityId).update({
          'admins': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'admins': FieldValue.arrayRemove([communityId])
        });

        await _firestore.collection('communities').doc(communityId).update({
          'roles': FieldValue.arrayRemove([{uid: role}]),
        });

        await _firestore.collection('profiles').doc(uid).update({
          'roles': FieldValue.arrayRemove([{communityId: role}]),
        });
        
        DocumentSnapshot profileSnap = await _firestore.collection('profiles').doc(uid).get();
        List enrolledComData = (profileSnap.data()! as dynamic)['enrolledComData'];
        DateTime joinDate = DateTime.now();
        String profileRole = "";
        String communityName = "";

        for (var hs in enrolledComData) {
          joinDate = hs[communityId]['joinDate'].toDate();
          profileRole = hs[communityId]['role'];
          communityName = hs[communityId]['communityName'];
        }

        await _firestore.collection('profiles').doc(uid).update({
          'enrolledComData': FieldValue.arrayRemove([{
            communityId: {
              "communityName": communityName,
              "joinDate": joinDate,
              "role": profileRole,
              }
            }])
        });

        await _firestore.collection('profiles').doc(uid).update({
          'pastComData': FieldValue.arrayUnion([{
            communityId: {
              "communityName": communityName,
              "joinDate": joinDate,
              "leftDate": DateTime.now(),
              "role": profileRole,
              }
            }])
        });

      }


        var communityGroupId = (snap.data()! as dynamic)['groups']['members'];

        await _firestore.collection('profiles')
                          .doc(uid)
                          .collection("messagesCommunities")
                          .doc(communityId)
                          .collection("messagesGroups")
                          .doc(communityGroupId)
                          .delete();
                          
        final refCommunities = FirebaseFirestore.instance.collection('communities');
        await refCommunities
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .update({
              'members': FieldValue.arrayRemove([uid]),
            });


    } catch(e) {
      print(e.toString());
      return e.toString();
    }
    return res;
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

   Future<String> sendContact({
    required String message,
    required String? email,
    required String? userid,
    required String? username,
  }) async {
    String res = "Some Error Occurred";
    String uid = const Uuid().v1();
    DateTime date = DateTime.now();
    try {
      if (message.isNotEmpty) {
        
        model.Contact _contact = model.Contact(
          username: username,
          uid: uid,
          userid: userid,
          email: email,
          message: message,
          date: date,
        );
        
        await _firestore
            .collection("contact")
            .doc(uid)
            .set(_contact.toJson());

        res = "success";
      } else {
        res = "Please enter a message";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> addAdmin(String communityId, String userId, String role) async{
    String res = "Some error occurred while adding new admin.";
    try {
      _firestore
            .collection('communities')
            .doc(communityId)
            .update({
          'roles': FieldValue.arrayUnion([{userId: role}]),
          'admins': FieldValue.arrayUnion([userId]),
        });

      _firestore
            .collection('profiles')
            .doc(userId)
            .update({
          'roles': FieldValue.arrayUnion([{communityId: role}]),
          'admins': FieldValue.arrayUnion([communityId]),
        });


        DocumentSnapshot profileSnap = await _firestore.collection('profiles').doc(userId).get();
        List enrolledComData = (profileSnap.data()! as dynamic)['enrolledComData'];
        DateTime joinDate = DateTime.now();
        String profileRole = "";
        String communityName = "";

        for (var hs in enrolledComData) {
          joinDate = hs[communityId]['joinDate'].toDate();
          profileRole = hs[communityId]['role'];
          communityName = hs[communityId]['communityName'];
        }

        await _firestore.collection('profiles').doc(userId).update({
          'enrolledComData': FieldValue.arrayRemove([{
            communityId: {
              "communityName": communityName,
              "joinDate": joinDate,
              "role": profileRole,
              }
            }])
        });

        await _firestore.collection('profiles').doc(userId).update({
          'pastComData': FieldValue.arrayUnion([{
            communityId: {
              "communityName": communityName,
              "joinDate": joinDate,
              "leftDate": DateTime.now(),
              "role": profileRole,
              }
            }])
        });

        await _firestore.collection('profiles').doc(userId).update({
          'enrolledComData': FieldValue.arrayUnion([{
            communityId: {
              "communityName": communityName,
              "joinDate": DateTime.now(),
              "role": role,
              }
            }])
        });


      DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
        var communityPhotoUrl = (snap.data()! as dynamic)['photoUrl'];
        var communityGroupId = (snap.data()! as dynamic)['groups']['admins'];

      DocumentSnapshot snap2 = await _firestore.collection('profiles').doc(userId).get();
          var senderUsername = (snap2.data()! as dynamic)['username'];
          var senderPhotoUrl = (snap2.data()! as dynamic)['photoUrl'];

        final refUsers = _firestore.collection('profiles');
        await refUsers
            .doc(userId)
            .collection("messagesCommunities")
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "$senderUsername joined to $communityName",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': userId,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'communityPhotoUrl': communityPhotoUrl,
              'communityName': communityName,
              'photoUrl': communityPhotoUrl,
              'username': communityName,
              'uid': communityId,
              });

        await refUsers
            .doc(userId)
            .collection("messagesCommunities")
            .doc(communityId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "$senderUsername joined to $communityName",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': userId,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'communityPhotoUrl': communityPhotoUrl,
              'communityName': communityName,
              'photoUrl': communityPhotoUrl,
              'username': communityName,
              'uid': communityId,
              });

        final refCommunities = FirebaseFirestore.instance.collection('communities');
        await refCommunities
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .update({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "$senderUsername joined to $communityName",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': userId,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'communityPhotoUrl': communityPhotoUrl,
              'communityName': communityName,
              'photoUrl': communityPhotoUrl,
              'username': communityName,
              'uid': communityId,
              'admins': FieldValue.arrayUnion([userId]),
              });


      res = 'New admin added as $role.';

    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> editAdmin(String communityId, String userId, String role, String prevRole) async{
    String res = "Some error occurred while adding new admin.";
    try {
      
        _firestore
            .collection('communities')
            .doc(communityId)
            .update({
          'roles': FieldValue.arrayRemove([{userId: prevRole}]),
        });

      _firestore
            .collection('communities')
            .doc(communityId)
            .update({
          'roles': FieldValue.arrayUnion([{userId: role}]),
        });

        _firestore
            .collection('profiles')
            .doc(userId)
            .update({
          'roles': FieldValue.arrayRemove([{communityId: prevRole}]),
        });
        
      _firestore
            .collection('profiles')
            .doc(userId)
            .update({
          'roles': FieldValue.arrayUnion([{communityId: role}]),
        });

        DocumentSnapshot profileSnap = await _firestore.collection('profiles').doc(userId).get();
        List enrolledComData = (profileSnap.data()! as dynamic)['enrolledComData'];
        DateTime joinDate = DateTime.now();
        String profileRole = "";
        String communityName = "";
        for (var hs in enrolledComData) {
          joinDate = hs[communityId]['joinDate'].toDate();
          profileRole = hs[communityId]['role'];
          communityName = hs[communityId]['communityName'];
        }

        await _firestore.collection('profiles').doc(userId).update({
          'enrolledComData': FieldValue.arrayRemove([{
            communityId: {
              "communityName": communityName,
              "joinDate": joinDate,
              "role": profileRole,
              }
            }])
        });

        await _firestore.collection('profiles').doc(userId).update({
          'pastComData': FieldValue.arrayUnion([{
            communityId: {
              "communityName": communityName,
              "joinDate": joinDate,
              "leftDate": DateTime.now(),
              "role": profileRole,
              }
            }])
        });
        await _firestore.collection('profiles').doc(userId).update({
          'enrolledComData': FieldValue.arrayUnion([{
            communityId: {
              "communityName": communityName,
              "joinDate": DateTime.now(),
              "role": role,
              }
            }])
        });

      res = 'User role is edited as $role.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteAdmin(String communityId, String userId, String role) async{
    String res = "Some error occurred while adding new admin.";
    try {
        _firestore
            .collection('communities')
            .doc(communityId)
            .update({
          'roles': FieldValue.arrayRemove([{userId: role}]),
          'admins': FieldValue.arrayRemove([userId]),
        });

      _firestore
            .collection('profiles')
            .doc(userId)
            .update({
          'roles': FieldValue.arrayRemove([{communityId: role}]),
          'admins': FieldValue.arrayRemove([communityId]),
        });


        DocumentSnapshot profileSnap = await _firestore.collection('profiles').doc(userId).get();
        List enrolledComData = (profileSnap.data()! as dynamic)['enrolledComData'];
        DateTime joinDate = DateTime.now();
        String profileRole = "";
        String communityName = "";

        for (var hs in enrolledComData) {
          joinDate = hs[communityId]['joinDate'].toDate();
          profileRole = hs[communityId]['role'];
          communityName = hs[communityId]['communityName'];
        }

        await _firestore.collection('profiles').doc(userId).update({
          'enrolledComData': FieldValue.arrayRemove([{
            communityId: {
              "communityName": communityName,
              "joinDate": joinDate,
              "role": profileRole,
              }
            }])
        });

        await _firestore.collection('profiles').doc(userId).update({
          'pastComData': FieldValue.arrayUnion([{
            communityId: {
              "communityName": communityName,
              "joinDate": joinDate,
              "leftDate": DateTime.now(),
              "role": profileRole,
              }
            }])
        });

        await _firestore.collection('profiles').doc(userId).update({
          'enrolledComData': FieldValue.arrayUnion([{
            communityId: {
              "communityName": communityName,
              "joinDate": DateTime.now(),
              "role": "Member",
              }
            }])
        });


        DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
        var communityGroupId = (snap.data()! as dynamic)['groups']['admins'];

        await _firestore
            .collection('communities')
            .doc(communityId)
            .collection('messagesGroups')
            .doc(communityGroupId)
            .update({
              'admins': FieldValue.arrayRemove([userId]),
            });

        await _firestore.collection('profiles')
                          .doc(userId)
                          .collection("messagesCommunities")
                          .doc(communityId)
                          .collection("messagesGroups")
                          .doc(communityGroupId)
                          .delete();

      res = 'Admin is deleted successfully.';

    } catch (err) {
      res = err.toString();
    }
    return res;
  }

Future<String> addCommunity(String desc ,String name, String userUid, String photoURL, GeoPoint location) async {
    String res = "Some error occurred";
    try {
      String communityGroupId = const Uuid().v1();
      String communityGroupId2 = const Uuid().v1();
      if (desc.isNotEmpty && name.isNotEmpty) {
        String communityId = const Uuid().v1();
        _firestore
            .collection('communities')
            .doc(communityId)
            .set({
          'admins': FieldValue.arrayUnion([userUid]),
          'bookmarkedUsers': FieldValue.arrayUnion([userUid]),
          'name': name,
          'username': name,
          'desc': desc,
          'enrolledUsers': FieldValue.arrayUnion([userUid]),
          'datePublished': DateTime.now(),
          'image': photoURL,
          'photoUrl': photoURL,
          'communityId': communityId,
          'roles': FieldValue.arrayUnion([{userUid: "Admin"}]),
          'requests': [],
          'type': 'Society',
          'location': location,
          'groups': {
            'members': communityGroupId,
            'admins': communityGroupId2,
            },
        });

            await _firestore.collection('profiles').doc(userUid).update({
                'admins': FieldValue.arrayUnion([communityId]),
                'enrolledCom': FieldValue.arrayUnion([communityId]),
                'bookmarkedCom': FieldValue.arrayUnion([communityId]),
                'roles': FieldValue.arrayUnion([{communityId: "Admin"}]),
        });

        final refCommunities = FirebaseFirestore.instance.collection('communities');
        await refCommunities
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': userUid,
              'senderPhotoUrl': photoURL,
              'senderUsername': name,
              'communityPhotoUrl': photoURL,
              'communityName': name,
              'photoUrl': photoURL,
              'username': name,
              'uid': communityGroupId,
              'isDefault': true,
              'members': FieldValue.arrayUnion([userUid]),
              'admins': FieldValue.arrayUnion([userUid]),
              });

        await refCommunities
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId2)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "",
              'communityId': communityId,
              'communityGroupId': communityGroupId2,
              'senderUserId': userUid,
              'senderPhotoUrl': photoURL,
              'senderUsername': name,
              'communityPhotoUrl': photoURL,
              'communityName': name,
              'photoUrl': photoURL,
              'username': "[Admins] $name",
              'uid': communityGroupId2,
              'isDefault': true,
              'members': FieldValue.arrayUnion([userUid]),
              'admins': FieldValue.arrayUnion([userUid]),
              });

        final refUsers = FirebaseFirestore.instance.collection('profiles');
        await refUsers
            .doc(userUid)
            .collection("messagesCommunities")
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': userUid,
              'senderPhotoUrl': photoURL,
              'senderUsername': name,
              'communityPhotoUrl': photoURL,
              'communityName': name,
              'photoUrl': photoURL,
              'username': name,
              'uid': communityGroupId,
              'isDefault': true,
              'members': FieldValue.arrayUnion([userUid]),
              'admins': FieldValue.arrayUnion([userUid]),
              });

        await refUsers
            .doc(userUid)
            .collection("messagesCommunities")
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId2)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "",
              'communityGroupId': communityGroupId2,
              'communityId': communityId,
              'senderUserId': userUid,
              'senderPhotoUrl': photoURL,
              'senderUsername': name,
              'communityPhotoUrl': photoURL,
              'communityName': name,
              'photoUrl': photoURL,
              'username': "[Admins] $name",
              'uid': communityGroupId2,
              'isDefault': true,
              'members': FieldValue.arrayUnion([userUid]),
              'admins': FieldValue.arrayUnion([userUid]),
              });

        await refUsers
            .doc(userUid)
            .collection("messagesCommunities")
            .doc(communityId)
            .set({
              'photoUrl': photoURL,
              'name': name,
              'communityId': communityId,
              });

        res = 'success';

      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

Future<String> updateNotificationOnEventUpdate(String communityId, String eventId, List selectedOptions, List prevSelectedOptions) async {
    String res = "Some error occurred";
    DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
    try {
      var admins = (snap.data()! as dynamic)['admins'];
        var members = (snap.data()! as dynamic)['enrolledUsers'];

        if (prevSelectedOptions[1] == true) {
          for(var memberUid in members) {
            await _firestore.collection('profiles').doc(memberUid).update({
                'notifications': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
                'notifications_new': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
        });
          }
        }

        if (selectedOptions[1] == true) {
          for(var memberUid in members) {
            await _firestore.collection('profiles').doc(memberUid).update({
                'notifications': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
                'notifications_new': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
        });
          }
        }
        if (prevSelectedOptions[0] == true) {
          for(var adminUid in admins) {
            await _firestore.collection('profiles').doc(adminUid).update({
                'notifications': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
                'notifications_new': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
        });
          }
        }
        if (selectedOptions[0] == true) {
          for(var adminUid in admins) {
            await _firestore.collection('profiles').doc(adminUid).update({
                'notifications': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
                'notifications_new': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
        });
          }
        }

      // CollectionReference _collectionRef = _firestore.collection('profiles');
      // QuerySnapshot querySnapshot = await _collectionRef.get();
      // final allData = querySnapshot.docs.map((doc) => doc.data()! as dynamic).toList();
      // for (var data in allData) {
      //   if(data['notifications_new'].isNotEmpty) {
      //     for (var notification in data['notifications_new']) {
      //       if(notification['eventId'] == eventId){
      //         await _firestore.collection('profiles').doc(data['uid']).update({
      //           'notifications_new': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
      //   });
      //   await _firestore.collection('profiles').doc(data['uid']).update({
      //           'notifications_new': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
      //   });
      //       }
      //     }
      //   }
      //   }
      // for (var data in allData) {
      //   if(data['notifications_new'].isNotEmpty) {
      //     for (var notification in data['notifications_new']) {
      //       if(notification['eventId'] == eventId){
      //         await _firestore.collection('profiles').doc(data['uid']).update({
      //           'notifications_new': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
      //   });
      //   await _firestore.collection('profiles').doc(data['uid']).update({
      //           'notifications_new': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
      //   });
      //       }
      //     }
      //   }
      //   if(data['notifications'].isNotEmpty) {
      //     for (var notification in data['notifications']) {
      //       if(notification['eventId'] == eventId){
      //          await _firestore.collection('profiles').doc(data['uid']).update({
      //           'notifications': FieldValue.arrayRemove([{"eventId": eventId, "communityId":communityId}]),
      //   });
      //         await _firestore.collection('profiles').doc(data['uid']).update({
      //           'notifications': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
      //           'notifications_new': FieldValue.arrayUnion([{"eventId": eventId, "communityId":communityId}]),
      //   });
      //       }
      //     }
      //   }
      // }
      res = "Notifications successfully updated.";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

Future<String> addCommentToEvent(String comment ,String username, String email, String photoURL, String userUid, String communityId, String eventId) async {
    String res = "Some error occurred";
    try {
      if (comment.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('communities')
            .doc(communityId)
            .collection('events')
            .doc(eventId)
            .collection('comments')
            .doc(commentId)
            .set({
          'username': username,
          'email': email,
          'comment': comment,
          'date': DateTime.now(),
          'image': photoURL,
          'userId': userUid,
          'communityId': communityId,
          'eventId': eventId,
          'commentId': commentId,
        });
        res = 'success';

            await _firestore.collection('profiles').doc(userUid).update({
                'comments': FieldValue.arrayUnion([{"communityId": communityId, "eventId": eventId, "commentId": commentId, "comment": comment}]),
        });

        await _firestore.collection('communities').doc(communityId).collection('events').doc(eventId).update({
                'commentsCounter': FieldValue.increment(1)
        });

      } else {
        res = "Please enter a comment.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteCommentFromEvent(String communityId, String eventId, String commentId, String userId, String comment) async {
    String res = "Some error occurred";
    try {

      await _firestore.collection('communities')
          .doc(communityId)
          .collection("events")
          .doc(eventId)
          .collection("comments")
          .doc(commentId)
          .delete();

      await _firestore.collection('profiles').doc(userId).update({
                'comments': FieldValue.arrayRemove([{"communityId": communityId, "eventId": eventId, "commentId": commentId, "comment": comment}]),
        });

      await _firestore.collection('communities').doc(communityId).collection('events').doc(eventId).update({
                'commentsCounter': FieldValue.increment(-1),
        });

      res = 'Comment is successfully deleted.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addPost(String communityId, String desc ,String name, String userUid,
      String username, String photoUrl, List photos) async {
    String res = "Some error occurred";
    try {
      DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
      //var image = (snap.data()! as dynamic)['image'];
      var communityName = (snap.data()! as dynamic)['name'];
      if (desc.isNotEmpty && name.isNotEmpty) {
        String postId = const Uuid().v1();
        _firestore
            .collection('communities')
            .doc(communityId)
            .collection('posts')
            .doc(postId)
            .set({
          'added_by': username,
          'name': name,
          'username': name,
          'userId': userUid,
          'desc': desc,
          'postId': postId,
          'datePublished': DateTime.now(),
          'image': photoUrl,
          'photoUrl': photoUrl,
          'photos': photos,
          'community_name': communityName,
          'communityId': communityId,
          'edited_on': "",
          'edited_by': "",
          'commentsCounter': 0,
          'type': 'Post',
        });
        res = 'success';

      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

Future<String> deletePost(String communityId, String postId) async {
    String res = "Some error occurred";
    try {

      await _firestore.collection('communities').doc(communityId).collection("posts").doc(postId).delete();

      res = 'Post is successfully deleted.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

Future<String> addCommentToPost(String comment ,String username, String email, String photoURL, String userUid, String communityId, String postId) async {
    String res = "Some error occurred";
    try {
      if (comment.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('communities')
            .doc(communityId)
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'username': username,
          'email': email,
          'comment': comment,
          'date': DateTime.now(),
          'image': photoURL,
          'userId': userUid,
          'communityId': communityId,
          'postId': postId,
          'commentId': commentId,
        });
        res = 'success';

            await _firestore.collection('profiles').doc(userUid).update({
                'postComments': FieldValue.arrayUnion([{"communityId": communityId, "postId": postId, "commentId": commentId, "comment": comment}]),
        });

        await _firestore.collection('communities').doc(communityId).collection('posts').doc(postId).update({
                'commentsCounter': FieldValue.increment(1)
        });

      } else {
        res = "Please enter a comment.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteCommentFromPost(String communityId, String postId, String commentId, String userId, String comment) async {
    String res = "Some error occurred";
    try {

      await _firestore.collection('communities')
          .doc(communityId)
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .delete();

      await _firestore.collection('profiles').doc(userId).update({
                'comments': FieldValue.arrayRemove([{"communityId": communityId, "postId": postId, "commentId": commentId, "comment": comment}]),
        });

      await _firestore.collection('communities').doc(communityId).collection('posts').doc(postId).update({
                'commentsCounter': FieldValue.increment(-1),
        });

      res = 'Comment is successfully deleted.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<int> followersNum(String userId) async {
    QuerySnapshot followersSnapshot =
        await _firestore.collection('profiles').doc(userId).collection('followers').get();
    return followersSnapshot.docs.length;
  }

Future<int> followingNum(String userId) async {
    QuerySnapshot followingSnapshot =
        await _firestore.collection('profiles').doc(userId).collection('following').get();
    return followingSnapshot.docs.length;
  }

Future<String> followUser(String currentUserId, String visitedUserId) async {
  String res = "Some error occurred.";
  try {
      DocumentSnapshot snap = await _firestore.collection('profiles').doc(visitedUserId).get();
      var username = (snap.data()! as dynamic)['username'];
      var photoUrl = (snap.data()! as dynamic)['photoUrl'];
      var firstName = (snap.data()! as dynamic)['firstName'];
      var lastName = (snap.data()! as dynamic)['lastName'];
      var email = (snap.data()! as dynamic)['email'];
      var bio = (snap.data()! as dynamic)['bio'];

      DocumentSnapshot snap2 = await _firestore.collection('profiles').doc(currentUserId).get();
      var username2 = (snap2.data()! as dynamic)['username'];
      var photoUrl2 = (snap2.data()! as dynamic)['photoUrl'];
      var firstName2 = (snap2.data()! as dynamic)['firstName'];
      var lastName2 = (snap2.data()! as dynamic)['lastName'];
      var email2 = (snap2.data()! as dynamic)['email'];
      var bio2 = (snap2.data()! as dynamic)['bio'];

        await _firestore.collection('profiles')
        .doc(currentUserId)
        .collection('following')
        .doc(visitedUserId)
        .set({
          'username': username,
          'photoUrl': photoUrl,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'bio': bio,
          'uid': visitedUserId,
        });
    await _firestore.collection('profiles')
        .doc(visitedUserId)
        .collection('followers')
        .doc(currentUserId)
        .set({
          'username': username2,
          'photoUrl': photoUrl2,
          'firstName': firstName2,
          'lastName': lastName2,
          'email': email2,
          'bio': bio2,
          'uid': currentUserId,
        });
    res = "User is successfully followed.";
  } catch(e) {
    res = e.toString();
  }
    return res;
  }

  Future<String> unFollowUser(String currentUserId, String visitedUserId) async {
    String res = "Some error occurred.";
    try {
      await _firestore.collection('profiles')
        .doc(currentUserId)
        .collection('following')
        .doc(visitedUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    await _firestore.collection('profiles')
        .doc(visitedUserId)
        .collection('followers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    res = "User is successfully unfollowed.";
    }
    catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<bool> isFollowingUser(
      String currentUserId, String visitedUserId) async {
    DocumentSnapshot followingDoc = await _firestore.collection('profiles')
        .doc(visitedUserId)
        .collection('followers')
        .doc(currentUserId)
        .get();
    return followingDoc.exists;
  }

  Future<String> uploadMessage(String receiverUserId, String senderUserId, String? message) async {
    String res = "Some error occurred.";
    try {
        DocumentSnapshot snap = await _firestore.collection('profiles').doc(receiverUserId).get();
          var receiverUsername = (snap.data()! as dynamic)['username'];
          var receiverPhotoUrl = (snap.data()! as dynamic)['photoUrl'];

        DocumentSnapshot snap2 = await _firestore.collection('profiles').doc(senderUserId).get();
          var senderUsername = (snap2.data()! as dynamic)['username'];
          var senderPhotoUrl = (snap2.data()! as dynamic)['photoUrl'];

        String messageId = const Uuid().v1();

        final refMessages = FirebaseFirestore.instance.collection('profiles')
            .doc(receiverUserId)
            .collection("messagesProfiles")
            .doc(senderUserId)
            .collection("messages")
            .doc(messageId);

        await refMessages.set({
          'messageId': messageId,
          'receiverUserId': receiverUserId,
          'senderUserId': senderUserId,
          'senderPhotoUrl': senderPhotoUrl,
          'senderUsername': senderUsername,
          'receiverPhotoUrl': receiverPhotoUrl,
          'receiverUsername': receiverUsername,
          'message': message,
          'createdAt': DateTime.now(),
      });


      final refMessages2 = FirebaseFirestore.instance.collection('profiles')
            .doc(senderUserId)
            .collection("messagesProfiles")
            .doc(receiverUserId)
            .collection("messages")
            .doc(messageId);

        await refMessages2.set({
          'messageId': messageId,
          'receiverUserId': receiverUserId,
          'senderUserId': senderUserId,
          'senderPhotoUrl': senderPhotoUrl,
          'senderUsername': senderUsername,
          'receiverPhotoUrl': receiverPhotoUrl,
          'receiverUsername': receiverUsername,
          'message': message,
          'createdAt': DateTime.now(),
      });

        final refUsers = FirebaseFirestore.instance.collection('profiles');
        await refUsers
            .doc(receiverUserId)
            .collection("messagesProfiles")
            .doc(senderUserId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': message,
              'receiverUserId': receiverUserId,
              'senderUserId': senderUserId,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'receiverPhotoUrl': receiverPhotoUrl,
              'receiverUsername': receiverUsername,
              'photoUrl': senderPhotoUrl,
              'username': senderUsername,
              'uid': senderUserId,
              });

        await refUsers
            .doc(senderUserId)
            .collection("messagesProfiles")
            .doc(receiverUserId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': message,
              'receiverUserId': receiverUserId,
              'senderUserId': senderUserId,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'receiverPhotoUrl': receiverPhotoUrl,
              'receiverUsername': receiverUsername,
              'photoUrl': receiverPhotoUrl,
              'username': receiverUsername,
              'uid': receiverUserId,
              });
      res = "Your message successfully sent.";
      } catch(e) {
        res = e.toString();
      }
    return res;
    }

    Future<String> uploadCommunityMessage(String communityId, String communityGroupId, String senderUserId, String? message, String communityGroupName) async {
    String res = "Some error occurred.";
    try {
        DocumentSnapshot snap = await _firestore.collection('communities').doc(communityId).get();
          var communityName = (snap.data()! as dynamic)['name'];
          var communityPhotoUrl = (snap.data()! as dynamic)['photoUrl'];

        DocumentSnapshot snap2 = await _firestore.collection('profiles').doc(senderUserId).get();
          var senderUsername = (snap2.data()! as dynamic)['username'];
          var senderPhotoUrl = (snap2.data()! as dynamic)['photoUrl'];

        String messageId = const Uuid().v1();

        final refMessages = FirebaseFirestore.instance.collection('profiles')
            .doc(senderUserId)
            .collection("messagesCommunities")
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .collection("messages")
            .doc(messageId);

        await refMessages.set({
          'messageId': messageId,
          'communityId': communityId,
          'communityGroupId': communityGroupId,
          'communityGroupName': communityGroupName,
          'senderUserId': senderUserId,
          'senderPhotoUrl': senderPhotoUrl,
          'senderUsername': senderUsername,
          'communityPhotoUrl': communityPhotoUrl,
          'communityName': communityName,
          'message': message,
          'createdAt': DateTime.now(),
      });


      final refMessages2 = FirebaseFirestore.instance.collection('communities')
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .collection("messages")
            .doc(messageId);

        await refMessages2.set({
          'messageId': messageId,
          'communityId': communityId,
          'communityGroupId': communityGroupId,
          'communityGroupName': communityGroupName,
          'senderUserId': senderUserId,
          'senderPhotoUrl': senderPhotoUrl,
          'senderUsername': senderUsername,
          'communityPhotoUrl': communityPhotoUrl,
          'communityName': communityName,
          'message': message,
          'createdAt': DateTime.now(),
      });

        final refUsers = FirebaseFirestore.instance.collection('profiles');
        await refUsers
            .doc(senderUserId)
            .collection("messagesCommunities")
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .update({
              'lastMessageTime': DateTime.now(),
              'lastMessage': message,
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'communityGroupName': communityGroupName,
              'senderUserId': senderUserId,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'communityPhotoUrl': communityPhotoUrl,
              'communityName': communityName,
              'photoUrl': communityPhotoUrl,
              'username': communityGroupName,
              'uid': senderUserId,
              });

        final refCommunities = FirebaseFirestore.instance.collection('communities');
        await refCommunities
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .update({
              'lastMessageTime': DateTime.now(),
              'lastMessage': message,
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'communityGroupName': communityGroupName,
              'senderUserId': senderUserId,
              'senderPhotoUrl': senderPhotoUrl,
              'senderUsername': senderUsername,
              'communityPhotoUrl': communityPhotoUrl,
              'communityName': communityName,
              'photoUrl': communityPhotoUrl,
              'username': communityGroupName,
              'uid': communityGroupId,
              });
      res = "Your message successfully sent.";
      } catch(e) {
        res = e.toString();
      }
    return res;
    }

    Future<String> addGroupChat(String communityId, List groupMembers, String groupName, String creatorId) async {
    String res = "Some error occurred";
    String communityGroupId = const Uuid().v1();
    try {
      if (groupMembers.isNotEmpty && groupName.isNotEmpty) {

        DocumentSnapshot profileSnap = await _firestore.collection('profiles').doc(creatorId).get();
        String photoURL = (profileSnap.data()! as dynamic)['photoUrl'];
        String name = (profileSnap.data()! as dynamic)['username'];

        DocumentSnapshot communitySnap = await _firestore.collection('communities').doc(communityId).get();
        String communityPhotoURL = (communitySnap.data()! as dynamic)['photoUrl'];
        String communityName = (communitySnap.data()! as dynamic)['name'];
        var admins = (communitySnap.data()! as dynamic)['admins'];
        var members = (communitySnap.data()! as dynamic)['enrolledUsers'];

        final refCommunities = FirebaseFirestore.instance.collection('communities');
        await refCommunities
            .doc(communityId)
            .collection("messagesGroups")
            .doc(communityGroupId)
            .set({
              'lastMessageTime': DateTime.now(),
              'lastMessage': "$name created the group.",
              'communityId': communityId,
              'communityGroupId': communityGroupId,
              'senderUserId': creatorId,
              'senderPhotoUrl': photoURL,
              'senderUsername': name,
              'communityPhotoUrl': communityPhotoURL,
              'communityName': communityName,
              'photoUrl': communityPhotoURL,
              'username': groupName,
              'uid': communityGroupId,
              'isDefault': false,
              'members': FieldValue.arrayUnion(members),
              'admins': FieldValue.arrayUnion(admins),
              });


        final refUsers = FirebaseFirestore.instance.collection('profiles');
        for (var memberId in groupMembers) {

          await refUsers
              .doc(memberId)
              .collection("messagesCommunities")
              .doc(communityId)
              .collection("messagesGroups")
              .doc(communityGroupId)
              .set({
                'lastMessageTime': DateTime.now(),
                'lastMessage': "$name created the group.",
                'communityId': communityId,
                'communityGroupId': communityGroupId,
                'senderUserId': creatorId,
                'senderPhotoUrl': photoURL,
                'senderUsername': name,
                'communityPhotoUrl': communityPhotoURL,
                'communityName': communityName,
                'photoUrl': communityPhotoURL,
                'username': groupName,
                'uid': communityGroupId,
                'isDefault': false,
                'members': FieldValue.arrayUnion(members),
                'admins': FieldValue.arrayUnion(admins),
                });

          await refUsers
              .doc(memberId)
              .collection("messagesCommunities")
              .doc(communityId)
              .set({
                'photoUrl': communityPhotoURL,
                'name': groupName,
                'communityId': communityId,
                });
        }
      }
      res = 'Group chat is successfully created.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

    Future<String> deleteGroupChat(String communityId, String communityGroupId) async {
    String res = "Some error occurred while deleting the group chat.";
    try {

      DocumentSnapshot communitySnap = await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('messagesGroups')
              .doc(communityGroupId)
              .get();

        var members = (communitySnap.data()! as dynamic)['members'];

      await _firestore.collection('communities').doc(communityId).collection("messagesGroups").doc(communityGroupId).delete();

      for (var memberId in members) {
        await _firestore.collection('profiles')
                .doc(memberId)
                .collection("messagesCommunities")
                .doc(communityId)
                .collection("messagesGroups")
                .doc(communityGroupId)
                .delete();
      }

      res = 'Group chat is successfully deleted.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addGroupAdmin(String userId, String communityId, String communityGroupId, String username) async {
    String res = "Some error occurred while making $username group admin to the group chat.";
    try {

       await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('messagesGroups')
              .doc(communityGroupId)
              .update({
                'admins': FieldValue.arrayUnion([userId]),
              });

      res = 'You successfully made $username admin.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

    Future<String> deleteGroupAdmin(String userId, String communityId, String communityGroupId, String username) async {
    String res = "Some error occurred while adding $username as group admin to the group chat.";
    try {

       await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('messagesGroups')
              .doc(communityGroupId)
              .update({
                'admins': FieldValue.arrayRemove([userId]),
              });

      res = 'You successfully remove admin from $username.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> kickGroupMember(String userId, String communityId, String communityGroupId, String username) async {
    String res = "Some error occurred while kicking $username from the group chat.";
    try {

       await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('messagesGroups')
              .doc(communityGroupId)
              .update({
                'members': FieldValue.arrayRemove([userId]),
                'admins': FieldValue.arrayRemove([userId]),
              });

      res = 'You successfully kicked $username.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addGroupMember(String userId, String communityId, String communityGroupId, String username) async {
    String res = "Some error occurred while adding $username to the group chat.";
    try {

       await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('messagesGroups')
              .doc(communityGroupId)
              .update({
                'members': FieldValue.arrayUnion([userId]),
              });

          DocumentSnapshot communitySnap = await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('messagesGroups')
              .doc(communityGroupId)
              .get();

        var members = (communitySnap.data()! as dynamic)['members'];
        members.add(userId);
        var admins = (communitySnap.data()! as dynamic)['admins'];
        var photoURL = (communitySnap.data()! as dynamic)['senderPhotoUrl'];
        var communityPhotoURL = (communitySnap.data()! as dynamic)['communityPhotoUrl'];
        var communityName = (communitySnap.data()! as dynamic)['communityName'];
        var groupName = (communitySnap.data()! as dynamic)['username'];

      await _firestore.collection('profiles')
                .doc(userId)
                .collection("messagesCommunities")
                .doc(communityId)
                .collection("messagesGroups")
                .doc(communityGroupId)
                .set({
                  'lastMessageTime': DateTime.now(),
                  'lastMessage': "You joined to the group.",
                  'communityId': communityId,
                  'communityGroupId': communityGroupId,
                  'senderUserId': userId,
                  'senderPhotoUrl': photoURL,
                  'senderUsername': username,
                  'communityPhotoUrl': communityPhotoURL,
                  'communityName': communityName,
                  'photoUrl': communityPhotoURL,
                  'username': groupName,
                  'uid': communityGroupId,
                  'isDefault': false,
                  'members': FieldValue.arrayUnion(members),
                  'admins': FieldValue.arrayUnion(admins),
                });

      res = 'You successfully added $username to the group chat.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> leaveGroupChat(String userId, String communityId, String communityGroupId) async {
    String res = "Some error occurred while leaving the group chat.";
    try {

            await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('messagesGroups')
              .doc(communityGroupId)
              .update({
                'members': FieldValue.arrayRemove([userId]),
                'admins': FieldValue.arrayRemove([userId]),
              });

        await _firestore.collection('profiles')
                .doc(userId)
                .collection("messagesCommunities")
                .doc(communityId)
                .collection("messagesGroups")
                .doc(communityGroupId)
                .delete();

      res = 'You successfully left the group chat.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

    Future<String> changeGroupChatName(String communityId, String communityGroupId, String groupName) async {
    String res = "Some error occurred while changing the group chat name.";
    try {

      DocumentSnapshot communitySnap = await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('messagesGroups')
              .doc(communityGroupId)
              .get();

        var members = (communitySnap.data()! as dynamic)['members'];

      await _firestore.collection('communities')
              .doc(communityId)
              .collection("messagesGroups")
              .doc(communityGroupId)
              .update({
                'username': groupName,
              });

      for (var memberId in members) {
        await _firestore.collection('profiles')
                .doc(memberId)
                .collection("messagesCommunities")
                .doc(communityId)
                .collection("messagesGroups")
                .doc(communityGroupId)
                .update({
                  'username': groupName
                });
      }

      res = 'Group chat name is successfully changed to $groupName.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

    Future<String> addParticipation(String? userId, String communityId, String eventId, String attendedWith) async {
    String res = "Some error occurred while participating to the event.";
    try {

            DocumentSnapshot eventSnap = await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('events')
              .doc(eventId)
              .get();

        var eventName = (eventSnap.data()! as dynamic)['name'];
        var communityName = (eventSnap.data()! as dynamic)['community_name'];
        var eventImage = (eventSnap.data()! as dynamic)['image'];
        var date = (eventSnap.data()! as dynamic)['date'];
        var endDate = (eventSnap.data()! as dynamic)['endDate'];
        var datePublished = (eventSnap.data()! as dynamic)['datePublished'];
        var dateAttended = DateTime.now();
        var eventDescription = (eventSnap.data()! as dynamic)['desc'];
        var isOnline = (eventSnap.data()! as dynamic)['isOnline'];
        var eventLocation = (eventSnap.data()! as dynamic)['location'];
        var eventLink = (eventSnap.data()! as dynamic)['eventLink'];

        await _firestore.collection('profiles')
                .doc(userId)
                .update({
                  'participation': FieldValue.arrayUnion([{
                    'communityId': communityId,
                    'eventId': eventId,
                    'userId': userId,
                    'eventName': eventName,
                    'communityName': communityName,
                    'eventImage': eventImage,
                    'date': date,
                    'endDate': endDate,
                    'datePublished': datePublished,
                    'dateAttended': dateAttended,
                    'eventDescription': eventDescription,
                    'isOnline': isOnline,
                    'eventLocation': eventLocation,
                    'eventLink': eventLink,
                    'attendedWith': attendedWith,
                  }]),
                });

      res = 'Participation is added successfully.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

}