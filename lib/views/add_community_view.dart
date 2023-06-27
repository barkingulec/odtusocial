import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social/widgets/community.dart';
import 'package:social/widgets/single_event.dart';
import '../services/auth/firestore_methods.dart';
import '../services/auth/storage_methods.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';
import '../widgets/enroll_button.dart';

class AddCommunityView extends StatefulWidget {
  const AddCommunityView({Key? key}) : super(key: key);

  @override
  _AddCommunityViewState createState() => _AddCommunityViewState();
}

class _AddCommunityViewState extends State<AddCommunityView> {
  final TextEditingController descEditingController =
      TextEditingController();
  final TextEditingController nameEditingController =
      TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userUid = ""; 
  String username = "";
  bool isLoading = false;
  String photoURL = logo2;
  var futurePhotoURL;
  bool isUploaded = false;
  final StorageMethods storage = StorageMethods();
  GeoPoint location = const GeoPoint(39.89171561144314, 32.78581707629186);

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    username = curUser.displayName!;
  }

  void addCommunity() async {
    try {
      String res = await FireStoreMethods().addCommunity(
        descEditingController.text,
        nameEditingController.text,
        userUid,
        photoURL,
        location,
      );

      if (res != 'success') {
        showSnackBar(context, res);
      }
      else {
        showSnackBar(context, "Society is successfully added.");
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
    return isLoading ? const CircularProgressIndicator() : Scaffold(
      appBar: AppBar(
      title: const Text(
        "Add Society", 
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
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                        padding: EdgeInsets.only(
                          top: 20.0,
                          bottom: 10.0,
                        ),
                        child: !isUploaded ? CustomImage(
                            photoURL,
                            radius: 20,
                            width: 300,
                            height: 150,
                          ) : FutureBuilder(
                            future: futurePhotoURL,
                            builder: ((BuildContext context, AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  return CustomImage(
                                          photoURL,
                                          radius: 20,
                                          width: 300,
                                          height: 150,     
                              );
                            }
                            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                                return const CircularProgressIndicator();
                            }
                            return Container();
                          })),
                      ),
                      const SizedBox(height: 10),
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
                  photoURL == logo2 ? const SizedBox() : const SizedBox(width: 20),
                      photoURL == logo2 ? const SizedBox() : GestureDetector(
                        onTap:() {
                          setState(() {
                            photoURL = logo2;
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
                  const SizedBox(height: 5),
                  buildEventNameField(),
                  const SizedBox(height: 10,),
                  buildDescField(),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Text("Location"),
                      const SizedBox(width: 5,),
                      Text("Select Location"),
                    ],
                  ),
                    const SizedBox(height: 20,),
                  //  ElevatedButton(
                  //         onPressed: addCommunity,
                  //         child: Text(
                  //           "Add Community",
                  //           style: TextStyle(
                  //             color: white,
                  //             fontSize: 18.0,
                  //           ),
                  //         ),
                  //         style: ButtonStyle(
                  //           backgroundColor: MaterialStateProperty.all(pink),
                  //         ),
                  //       ),
                    EnrollButton(
                          text: 'Add Society',
                          backgroundColor: Colors.white,
                          textColor: pink,
                          borderColor: pink,
                          function: addCommunity,
                          height: 50,
                              width: 200,
                              radius: 30,
                              fontSize: 16,
                    ),
                    const SizedBox(height: 20),
                ],
              ),
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
              "Society Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: nameEditingController,
          decoration: const InputDecoration(
            hintText: "Enter Society Name",
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
          maxLines: 5,
          controller: descEditingController,
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