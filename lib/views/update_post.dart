import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:social/services/auth/firestore_methods.dart';
import 'package:social/widgets/custom_image.dart';

import '../services/auth/storage_methods.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';
import '../utils/utils.dart';
import '../widgets/enroll_button.dart';

class UpdatePost extends StatefulWidget {
  final communityId;
  final postId;
  const UpdatePost({super.key, this.communityId, this.postId});

  @override
  State<UpdatePost> createState() => _UpdatePostState();
}

class _UpdatePostState extends State<UpdatePost> {
    var communityData = {};
  var postData = {};
  var postRef;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isLoading = false;
  bool _nameValid = true;
  bool _descValid = true;
  String? username = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isUploaded= false;
  String photoURL = "";
  var futurePhotoURL;
  final StorageMethods storage = StorageMethods();
  var photos = [];

  @override
  void initState() {
    super.initState();
    getData();
    final User? curUser = auth.currentUser;
    username = curUser!.displayName;
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var communitySnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();

      communityData = communitySnap.data()!;

      var postSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('posts')
          .doc(widget.postId)
          .get();

      postData = postSnap.data()!;

      postRef = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('posts')
          .doc(widget.postId);

      setState(() {
        nameController = TextEditingController(text: postData['name']);
        descController = TextEditingController(text: postData['desc']);
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
      photoURL = postData['image'];
      photos = postData['photos'];
    });
  }

  Column buildEventNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Post Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Update Post Name",
            errorText: _nameValid ? null : "Post name is too short",
          ),
        )
      ],
    );
  }

  Column buildDescField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 12.0),
          child: Text(
            "Description",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: descController,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              gapPadding: 1,
            ),
            hintText: "Update Description",
            errorText: _descValid ? null : "Description is too long",
          ),
        )
      ],
    );
  }

  updatePost() {
    setState(() {
      nameController.text.trim().length < 3 ||
              nameController.text.isEmpty
          ? _nameValid = false
          : _nameValid = true;
      descController.text.trim().length > 300
          ? _descValid = false
          : _descValid = true;
    });

    if (_nameValid && _descValid) {
      postRef.update({
        "name": nameController.text,
        "username": nameController.text,
        "desc": descController.text,
        "edit_history": FieldValue.arrayUnion([{username: DateTime.now()}]),
        "image": photoURL,
        "photoUrl": photoURL,
        "photos": photos,
      });
      showSnackBar(context, "Post updated!");
      Navigator.pop(context);
    }
  }

  uploadImage() async {
                          final results = await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                            type: FileType.image,
                          );
                          if (results == null) {
                            showSnackBar(context, "No file selected");
                            return null;
                          }
                          final paths = results.paths.map((path) => path!).toList();
                          final fileNames = results.names.map((path) => path!).toList();
                          
                          if (paths.isNotEmpty) {
                            photos.removeLast();
                          }

                          for (var i = 0; i < paths.length; i++) {
                            futurePhotoURL = storage.uploadFile(paths[i], fileNames[i]);
                            futurePhotoURL.then((String result){
                              photos.add(result);
                              setState(() {
                                photoURL = photos[0];
                              });
                            });
                          }
                          
                          setState(() {
                            photoURL = photos[0];
                          });
                        }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
        title: Text(
          "Update Post",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height + 220,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: PageView.builder(
                        itemCount: photos.length,
                        pageSnapping: true,
                        itemBuilder: (context,ind){
                        return Column(
                          children: [
                            CustomImage(
                                photos[ind],
                                radius: 10,
                                width: MediaQuery.of(context).size.width - 80,
                                height: 240,
                              ),
                              const SizedBox(height: 18,),
                            Text("${ind+1} / ${photos.length}", style: const TextStyle(fontSize: 18),),
                          ],
                        );
                      }),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                    onTap: uploadImage,
                    child: Row(
                      children: [
                        Icon(Icons.file_upload_outlined, color: pink.withOpacity(.8)),
                        const SizedBox(width: 5),
                        Text("Upload"),
                      ],
                    ),
                  ),
                  photoURL == communityData['image'] ? const SizedBox() : const SizedBox(width: 20),
                      photoURL == communityData['image'] ? const SizedBox() : GestureDetector(
                        onTap:() {
                          setState(() {
                            photoURL = communityData['image'];
                            photos = [communityData['image']];
                          });
                        },
                        child: Row(
                          children: [   
                              SvgPicture.asset("assets/delete.svg", color: pink.withOpacity(.8), width: 20, height: 20,),
                              const SizedBox(width: 5),
                              Text("Remove"),
                        ],
                        ),
                      ),
                            ],
                          ),
                    
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                buildEventNameField(),
                                buildDescField(),
                              ],
                            ),
                          ),
                    
                               const SizedBox(height: 30),
                          EnrollButton(
                              text: 'Update Post',
                              backgroundColor: Colors.white,
                              textColor: pink,
                              borderColor: pink,
                              function: updatePost,
                              height: 50,
                                width: 200,
                                radius: 30,
                                fontSize: 16,
                                  ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}