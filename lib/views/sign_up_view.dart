import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social/services/auth/auth_methods.dart';
import 'package:social/views/login_view.dart';
import 'package:social/utils/colors.dart';
import 'package:social/utils/utils.dart';
import 'package:social/views/verify_email_view.dart';
import 'package:social/widgets/terms_and_conditions.dart';
import 'package:social/widgets/text_field_input.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/custom_image.dart';
import '../widgets/privacy_policy.dart';
import 'home_view.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _usernameValid = true;
  bool _emailValid = true;
  bool _passwordValid = true;
  bool obscure = true;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

Column buildUserNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
         Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: SvgPicture.asset("assets/profile.svg", color: pink.withOpacity(1), width: 27, height: 27,),
            ),
        TextField(
          controller: _usernameController,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "Username",
            hintStyle: TextStyle(fontSize: 15),
            errorText: _usernameValid ? null : "Username is not valid.",
          ),
        )
      ],
    );
  }

  Column buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: SvgPicture.asset("assets/email2.svg", color: pink.withOpacity(1), width: 27, height: 27,),
            ),
        TextField(
          controller: _emailController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: "ODTÜ Email",
            hintStyle: TextStyle(fontSize: 15),
          ),
        )
      ],
    );
  }

    Column buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
         Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: SvgPicture.asset("assets/password.svg", color: pink.withOpacity(1), width: 27, height: 27,),
            ),
        TextField(
          controller: _passwordController,
          obscureText: obscure,
          autocorrect: false,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: TextStyle(fontSize: 15),
            prefixIcon: SvgPicture.asset("assets/dot.svg", color: Colors.transparent, width: 12, height: 12,),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscure = !obscure;
                });
              },
              icon: obscure ? Icon(Icons.remove_red_eye_outlined, color: pink.withOpacity(.8)) : Icon(Icons.remove_red_eye, color: pink.withOpacity(.8))
          ),
        ),
      ),
    ],
    );
  }

signUpUser() async {
  setState(() {
      _usernameController.text.trim().length < 3 ||
              _usernameController.text.isEmpty
          ? _usernameValid = false
          : _usernameValid = true;
      _emailController.text.trim().split('@')[1] == 'metu.edu.tr'
          ? _emailValid = true
          : _emailValid = false;
    });

    if (_usernameValid && _emailValid && _passwordValid) {
    
                  String res = await AuthMethods().signUpUser(
                    email: _emailController.text,
                    password: _passwordController.text,
                    username: _usernameController.text,);
                    if (res == 'success') {
                    
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const VerifyEmailView()), (route) => false);
                    } else {
                      
                    }
                    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height + 200,
          //padding: const EdgeInsets.symmetric(horizontal: 32),
          //width: double.infinity,
          decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          //stops: [0, 1],
                          colors: [
                            // pink.withOpacity(.06), 
                            // pink.withOpacity(.45),
                            pink.withOpacity(.01),
                            pink.withOpacity(.02),
                            pink.withOpacity(.04),
                            pink.withOpacity(.06),
                            pink.withOpacity(.085),
                            pink.withOpacity(.12),
                          ],
                        )
                      ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flexible(
                //   flex: 2,
                //   child: Container(),
                // ),
                SizedBox(height: MediaQuery.of(context).size.height / 20 ),
                CustomImage(
                  //'https://images.unsplash.com/photo-1596638787647-904d822d751e?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MTF8fGZhc2hpb258ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
                  logo2,
                  height: 180,
                  width: 360,
                  radius: 15,
                ),
                const SizedBox(
                  height: 64,
                ),
                Column(
                  children: <Widget>[
                    buildUserNameField(),
                    buildEmailField(),
                    buildPasswordField(),
                  ],
                ),
                const SizedBox(
                  height: 48,
                ),
                InkWell(
                  onTap: signUpUser,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration:  ShapeDecoration(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          //stops: [0, 1],
                          colors: [
                            // pink.withOpacity(.06), 
                            // pink.withOpacity(.45),
                            pink.withOpacity(.74),
                            pink.withOpacity(.63),
                            pink.withOpacity(.52),
                            pink.withOpacity(.46),
                            pink.withOpacity(.42),
                            pink.withOpacity(.40),
                            pink.withOpacity(.42),
                            pink.withOpacity(.46),
                            pink.withOpacity(.52),
                            pink.withOpacity(.63),
                            pink.withOpacity(.74),
                          ],
                        ),
                      //color: pink.withOpacity(.9),
                    ),
                    child: const Text(
                      "CREATE ACCOUNT", 
                      style: TextStyle(
                        color: white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                  child: Container(),
                  flex: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: const Text(
                        'Already have an account?',
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                      child: Container(
                        child: const Text(
                          ' Login.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                          'By creating an account you agree to our',
                          textAlign: TextAlign.center,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: () async{
                        Uri url = Uri.parse("https://doc-hosting.flycricket.io/odtusocial-terms-of-use/4ceea67d-cbd4-4777-be00-1a14bf2e1468/terms");
                        await launchUrl(url);
                        },
                    child: Text(
                              'Terms & Conditions,',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: () async{
                        Uri url = Uri.parse("https://doc-hosting.flycricket.io/odtusocial-privacy-policy/3d0b198c-136b-4de6-8003-0e155ed9ec5b/privacy");
                        await launchUrl(url);
                        },
                    child: Text(
                              'Privacy Policy.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     GestureDetector(
                //       onTap: () async{
                //         Uri url = Uri.parse("https://doc-hosting.flycricket.io/odtusocial-terms-of-use/4ceea67d-cbd4-4777-be00-1a14bf2e1468/terms");
                //         await launchUrl(url);
                //         },
                //       child: Container(
                //         child: const Text(
                //           ' Terms & Conditions',
                //           style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         padding: const EdgeInsets.symmetric(vertical: 8),
                //       ),
                //     ),
                  
                    
                //   ],),
                  
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Container(
                  //     child: const Text(
                  //       'and',
                  //     ),
                  //     padding: const EdgeInsets.symmetric(vertical: 8),
                  //   ),
                  
                  //   GestureDetector(
                  //     onTap: () async{
                  //       Uri url = Uri.parse("https://doc-hosting.flycricket.io/odtusocial-privacy-policy/3d0b198c-136b-4de6-8003-0e155ed9ec5b/privacy");
                  //       await launchUrl(url);
                  //     },
                  //     child: Container(
                  //       child: const Text(
                  //         ' Privacy Policy.',
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       padding: const EdgeInsets.symmetric(vertical: 8),
                  //     ),
                  //   ),
                  //   ],
                  // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}