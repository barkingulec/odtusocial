import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';

import '../services/auth/storage_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';
import '../widgets/enroll_button.dart';

class EditCommunityView extends StatefulWidget {
  final communityId;
  const EditCommunityView({super.key, this.communityId});

  @override
  State<EditCommunityView> createState() => _EditCommunityViewState();
}

class _EditCommunityViewState extends State<EditCommunityView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var communityData = {};
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  bool isUploaded= false;
  bool _nameValid = true;
  bool _bioValid = true;
  var communityRef;
  String photoURL = "";
  var futurePhotoURL;
  final StorageMethods storage = StorageMethods();
  GeoPoint location = const GeoPoint(39.89171561144314, 32.78581707629186);

  @override
  void initState() {
    super.initState();
    getData();
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

      communityRef = FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId);

      setState(() {
        nameController = TextEditingController(text: communityData['name']);
        bioController = TextEditingController(text: communityData['desc']);
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
      photoURL = communityData['image'];
    });
  }

    Column buildEventNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Update Name",
            errorText: _nameValid ? null : "Society name is too short",
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
          padding: EdgeInsets.only(top: 16.0, bottom: 12,),
          child: Text(
            "Description",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              gapPadding: 1,
            ),
            hintText: "Update Description",
            errorText: _bioValid ? null : "Description is too long",
          ),
        )
      ],
    );
  }

  updateProfile() async {
    setState(() {
      nameController.text.trim().length < 10 ||
              nameController.text.isEmpty
          ? _nameValid = false
          : _nameValid = true;
      bioController.text.trim().length > 750
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_nameValid && _bioValid) {
      communityRef.update({
        "name": nameController.text,
        "username": nameController.text,
        "desc": bioController.text,
        "image": photoURL,
        "photoUrl": photoURL,
        "location": location,
      });

      var postQuery = await FirebaseFirestore.instance.collection("communities").doc(widget.communityId).collection("posts").get();
      for(var postDoc in postQuery.docs)
        {
          await FirebaseFirestore.instance
              .collection("communities")
              .doc(widget.communityId)
              .collection("posts")
              .doc(postDoc.id)
              .update({
                "community_name": nameController.text,
                "community_image": photoURL,
              });
        }

      var eventQuery = await FirebaseFirestore.instance.collection("communities").doc(widget.communityId).collection("events").get();
      for(var eventDoc in eventQuery.docs)
        {
          await FirebaseFirestore.instance
              .collection("communities")
              .doc(widget.communityId)
              .collection("events")
              .doc(eventDoc.id)
              .update({
                "community_name": nameController.text,
                "community_image": photoURL,
              });
        }

      }

      

      showSnackBar(context, "Society updated!");
      Navigator.pop(context);
    }
  

uploadImage() async {
                          final results = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.image,
                          );
                          if (results == null) {
                            showSnackBar(context, "No file selected");
                            return null;
                          }
                          final path = results.files.single.path!;
                          final fileName = results.files.single.name;
                          
                          futurePhotoURL = storage.uploadFile(path, fileName);
                          futurePhotoURL.then((String result){
                            setState(() {
                                  photoURL = result;
                                });
                            });
                          isUploaded = true;
                            // .then((value) => 
                            // print('Done.'));
                          //var url = storage.downloadURL(fileName);
                          setState(() {
                            //photoURL = url;
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
          "Update Society",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: 
          isLoading ? const Center(child: CircularProgressIndicator()) : 
          ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    right: 20.0,
                    left: 20.0,),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20.0,
                          bottom: 10.0,
                        ),
                        child: !isUploaded ? CustomImage(
                            communityData['image'],
                            radius: 20,
                            width: 360,
                            height: 200,
                          ) : FutureBuilder(
                            future: futurePhotoURL,
                            builder: ((BuildContext context, AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  return CustomImage(
                                          photoURL,
                                          radius: 20,
                                          width: 360,
                                          height: 200,
                              );
                            }
                            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                                return const CircularProgressIndicator();
                            }
                            return Container();
                          })),
                      ),
                      // ElevatedButton(
                      //   onPressed: uploadImage,
                      //   style: ElevatedButton.styleFrom(
                      //       backgroundColor: pink,
                      //     ),
                      //   child: Text("Upload Image")
                      //   ),
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
                      Column(
                        children: <Widget>[
                          buildEventNameField(),
                          const SizedBox(height: 5,),
                          buildDescField(),
                          const SizedBox(height: 10,),
                        ],
                      ),
                      const SizedBox(height: 10,),
                  Row(
                    children: [
                      Text("Location"),
                      const SizedBox(width: 5,),
                      Text("Select Location"),
                    ],
                  ),
                 const SizedBox(height: 20),
                      // ElevatedButton(
                      //   onPressed: updateProfile,
                      //   child: Text(
                      //     "Update Community",
                      //     style: TextStyle(
                      //       color: white,
                      //       fontSize: 18.0,
                      //     ),
                      //   ),
                      //   style: ButtonStyle(
                      //     backgroundColor: MaterialStateProperty.all(pink),
                      //   ),
                      // ),
                      EnrollButton(
                              text: 'Update Society',
                              backgroundColor: Colors.white,
                              textColor: pink,
                              borderColor: pink,
                              function: updateProfile,
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
    );
  }
}