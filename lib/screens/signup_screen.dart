import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/responsive/mobileScreen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/webScreen_layout.dart';
import 'package:instagram_clone/screens/login_screens.dart';
import 'package:instagram_clone/utilis/utilis.dart';
import '../utilis/colors.dart';
import '../utilis/global.dart';
import '../widgets/text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        photoUrl: "",
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        //file: null
    );
    setState(() {
      _isLoading = false;
    });
    if (res != "success") {
      //Get.offAll(AddPostScreen());
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ResponsiveLayoutScreen(
              webScreenLayout: WebscreenLayout(),
              mobileScreenLayout: MobilescreenLayout())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
              padding: MediaQuery.of(context).size.width > webScreenSize
                  ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
                  : const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(),
              flex: 2,
            ),
            //svg image
            SvgPicture.asset(
              "assets/image/Instagram.svg",
              color: primaryColor,
              height: 64,
            ),

            const SizedBox(
              height: 64,
            ),

            //text field input for username
            TextFieldInput(
                textEditingController: _usernameController,
                hintText: "Enter your username",
                textInputType: TextInputType.text),

            const SizedBox(
              height: 24,
            ),

            //text field input for email
            TextFieldInput(
                textEditingController: _emailController,
                hintText: "Enter your email",
                textInputType: TextInputType.emailAddress),

            const SizedBox(
              height: 24,
            ),

            //text field input for password
            TextFieldInput(
                textEditingController: _passwordController,
                hintText: "Enter your password",
                textInputType: TextInputType.text),

            const SizedBox(
              height: 24,
            ),

            //text field input for bio
            TextFieldInput(
                textEditingController: _bioController,
                hintText: "Enter your bio",
                textInputType: TextInputType.text),

            const SizedBox(
              height: 24,
            ),

            //button login
            GestureDetector(
              onTap: signUpUser,
              child: Container(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.black),
                      ),
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)))),
              ),
            ),

            const SizedBox(
              height: 12,
            ),
            Flexible(
              child: Container(),
              flex: 2,
            ),

            //Transmitting to signing up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text("Already have an account"),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () => Get.to(LoginScreen()),
                  child: Container(
                    child: Container(
                      child: const Text(
                        "Log In",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
