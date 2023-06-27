import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social/services/auth/storage_methods.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';
import '../widgets/enroll_button.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var profileData = {};
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool isLoading = false;
  bool _nameValid = true;
  bool _bioValid = true;
  bool _firstNameValid = true;
  bool _lastNameValid = true;
  bool isUploaded = false;
  String? uid = "";
  String photoURL = "";
  String prevPhoto = "";
  var futurePhotoURL;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final StorageMethods storage = StorageMethods();
  var profileRef;

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    uid = curUser!.uid;
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var profileSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid)
          .get();

      profileData = profileSnap.data()!;

      profileRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid);

      setState(() {
        nameController = TextEditingController(text: profileData['username']);
        bioController = TextEditingController(text: profileData['bio']);
        firstNameController = TextEditingController(text: profileData['firstName']);
        lastNameController = TextEditingController(text: profileData['lastName']);
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      photoURL = profileData['photoUrl'];
      isLoading = false;
    });
  }

    Column buildEventNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Username",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Update Username",
            errorText: _nameValid ? null : "Username is too short",
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
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Biography",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Biography",
            errorText: _bioValid ? null : "Biography is too long",
          ),
        )
      ],
    );
  }

  Column buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "First Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(
            hintText: "Update First Name",
            errorText: _firstNameValid ? null : "First name is too long",
          ),
        )
      ],
    );
  }

  Column buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Last Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(
            hintText: "Update Last Name",
            errorText: _lastNameValid ? null : "Last name is too long",
          ),
        )
      ],
    );
  }

updateFirebaseUserName() async {
      Map<String, String> userMap = {'name': nameController.text}; 
      
      //await Firebase(uid: uid).uploadUserInfo(userMap); 
}

  updateProfile() {
    setState(() {
      nameController.text.trim().length < 3 ||
              nameController.text.isEmpty
          ? _nameValid = false
          : _nameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
      firstNameController.text.trim().length > 20
          ? _firstNameValid = false
          : _firstNameValid = true;
      lastNameController.text.trim().length > 14
          ? _lastNameValid = false
          : _lastNameValid = true;
    });

    if (_nameValid && _bioValid && _lastNameValid && _firstNameValid) {
      profileRef.update({
        "username": nameController.text,
        "bio": bioController.text,
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "photoUrl": photoURL,
      });

      showSnackBar(context, "Profile updated!");
      Navigator.pop(context);
    }
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
                                  prevPhoto = photoURL;
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
          "Update Profile",
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
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20.0,
                          bottom: 10.0,
                        ),
                        child: 
                        //!isUploaded ? 
                        CustomImage(
                            photoURL,
                            radius: 20,
                            width: 125,
                            height: 125,
                          ) 
                          // : FutureBuilder(
                          //   future: futurePhotoURL,
                          //   builder: ((BuildContext context, AsyncSnapshot<String> snapshot) {
                          //     if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                          //         return CustomImage(
                          //                 photoURL,
                          //                 radius: 20,
                          //                 width: 125,
                          //                 height: 125,     
                          //     );
                          //   }
                          //   if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                          //       return const CircularProgressIndicator();
                          //   }
                          //   return Container();
                          // })),
                      ),
                      const SizedBox(height: 15),
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
                  (photoURL != profileData['photoUrl']) | (logo == profileData['photoUrl']) | (photoURL == logo) | (prevPhoto == logo) ? const SizedBox() : const SizedBox(width: 20),
                      (photoURL != profileData['photoUrl']) | (logo == profileData['photoUrl']) | (photoURL == logo) | (prevPhoto == logo) ? const SizedBox() : GestureDetector(
                        onTap:() {
                          setState(() {
                            prevPhoto = photoURL;
                            photoURL = logo;
                          });
                        },
                        child: Row(
                          children: [   
                              SvgPicture.asset("assets/delete.svg", color: pink.withOpacity(.8), width: 20, height: 20,),
                              const SizedBox(width: 5),
                              Text("Delete"),
                        ],
                        ),
                      ),
                      (photoURL == profileData['photoUrl']) | (photoURL == logo) ? const SizedBox() : const SizedBox(width: 20),
                      (photoURL == profileData['photoUrl']) | (photoURL == logo) ? const SizedBox() : GestureDetector(
                        onTap:() {
                          setState(() {
                            prevPhoto = photoURL;
                            photoURL = profileData['photoUrl'];
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
                  
                      // ElevatedButton(
                      //   onPressed: uploadImage,
                      //   child: Text("Upload Image")
                      //   ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildEventNameField(),
                            buildFirstNameField(),
                            buildLastNameField(),
                            buildDescField(),
                          ],
                        ),
                      ),
                 const SizedBox(height: 20),
                      // ElevatedButton(
                      //   onPressed: updateProfile,
                      //   child: Text(
                      //     "Update Profile",
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
                          text: 'Update Profile',
                          backgroundColor: Colors.white,
                          textColor: pink,
                          borderColor: pink,
                          function: updateProfile,
                          height: 30,
                          width: 120,
                    ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}