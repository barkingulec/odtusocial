import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';

import '../services/auth/firestore_methods.dart';
import '../services/auth/storage_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';
import '../widgets/enroll_button.dart';

class AddPostView extends StatefulWidget {
  final communityId;
  const AddPostView({super.key, this.communityId});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  var communityData = {};
  final TextEditingController descEditingController =
      TextEditingController();
  final TextEditingController nameEditingController =
      TextEditingController();
  DateTime date = DateTime.now();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userUid = ""; 
  String username = "";
  bool isLoading = false;
  String photoURL = "";
  var futurePhotoURL;
  final StorageMethods storage = StorageMethods();
  var photos = [];

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    username = curUser.displayName!;
    getData();
  }

void addPost() async {
    try {
      String res = await FireStoreMethods().addPost(
        widget.communityId,
        descEditingController.text,
        nameEditingController.text,
        userUid,
        username,
        photoURL,
        photos,
      );
      if (res != 'success') {
        showSnackBar(context, res);
      }
      else {
        showSnackBar(context, "Post is successfully added.");
        Navigator.pop(context);
      }
      setState(() {
        descEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
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

      setState(() {
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
      photoURL = communityData['image'];
      photos.add(photoURL);
    });
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
    return isLoading ? const Center(child: CircularProgressIndicator()) : Scaffold(
      appBar: AppBar(
      title: const Text(
        "Add Post", 
        style: TextStyle(color: black),
      ),
      iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
    ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Expanded(
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
                  Expanded(
                    flex: 0,
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
                                    buildEventNameField(),
                                    const SizedBox(height: 10,),
                                    buildDescField(),
                                     const SizedBox(height: 20,),
                                    EnrollButton(
                                  text: 'Add Post',
                                  backgroundColor: Colors.white,
                                  textColor: pink,
                                  borderColor: pink,
                                  function: addPost,
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
          controller: nameEditingController,
          decoration: const InputDecoration(
            hintText: "Enter Post Name",
            hintStyle: TextStyle(fontSize: 15),
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
          padding: EdgeInsets.only(top: 16.0, bottom: 12),
          child: Text(
            "Description",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: descEditingController,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              gapPadding: 1,
            ),
            hintText: "Enter Description",
            hintStyle: TextStyle(fontSize: 15),
          ),
        )
      ],
    );
  }
}