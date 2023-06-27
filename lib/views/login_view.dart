import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social/views/home_view.dart';
import 'package:social/services/auth/auth_methods.dart';
import 'package:social/views/sign_up_view.dart';
import 'package:social/utils/colors.dart';
import 'package:social/utils/utils.dart';
import 'package:social/views/verify_email_view.dart';
import 'package:social/widgets/text_field_input.dart';

import '../widgets/custom_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const VerifyEmailView()), (route) => false);
    } else {
      showSnackBar(context, "Wrong email or username.");
    }
  }

  Future resetPassword() async {  
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(),));
        
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
            showSnackBar(context, "Password reset email is sent.");
            Navigator.of(context).popUntil((route) => route.isFirst);
          } catch (e) {
            showSnackBar(context, e.toString());
            Navigator.pop(context);
          }
  }
  Future snackBar() async {
    showSnackBar(context, "Please enter your email into above field.");
  }

Column buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 16.0),
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
            padding: EdgeInsets.only(top: 26.0),
            child: SvgPicture.asset("assets/password.svg", color: pink.withOpacity(1), width: 27, height: 27,),
            ),
        TextField(
          controller: _passwordController,
          obscureText: obscure,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flexible(
                //   flex: 1,
                //   child: Container(),
                // ),
                SizedBox(height: MediaQuery.of(context).size.height / 10 ),
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
                    buildEmailField(),
                    buildPasswordField(),
                  ],
                ),
                const SizedBox(
                  height: 42,
                ),
                InkWell(
                  onTap: loginUser,
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
                          colors: [
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
                      "LOGIN", 
                      style: TextStyle(
                        color: white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                // const SizedBox(
                //   height: 12,
                // ),
                // Flexible(
                //   child: Container(),
                //   flex: 1,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: const Text(
                        'Dont have an account?',
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      ),
                      child: Container(
                        child: const Text(
                          ' Signup.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _emailController.text.isNotEmpty ? () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text('Reset Password'),
                                content: Text("Password reset link will be sent to your email."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: resetPassword,
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                        } : snackBar,
                      child: Container(
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}