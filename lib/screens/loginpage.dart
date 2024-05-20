import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:text_to_speech/screens/signuppage.dart';
import 'package:text_to_speech/utils/colors/colors.dart';
import 'package:text_to_speech/utils/widgets/navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = "";
  final _formKey = GlobalKey<FormState>();
  bool isLogin = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  loginUser() async {
    try {
      setState(() {
        isLogin = true;
      });

      // ignore: unused_local_variable
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text,
            password: passController.text,
          )
          .then((value) => {
                Fluttertoast.showToast(msg: "Login Succesfully!"),
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavBar(),
                  ),
                ),
              });
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                "assets/images/6310507.jpg",
                fit: BoxFit.cover,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to ",
                    style: TextStyle(
                        fontSize: 30,
                        color: greyColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Speecho",
                    style: TextStyle(
                        fontSize: 30,
                        color: blueColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email field cant be empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    name = value;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 4, color: greyColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: blueColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Email",
                    hintText: "Enter Your Email",
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  controller: passController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password field cant be empty";
                    } else if (value.length < 6) {
                      return "Password must contains minimum 6 Characters";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          width: 4,
                          color: greyColor,
                        )),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: blueColor,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: "Enter Your Password",
                    labelText: "Password",
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(
                height: 50,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text("Dont have an Account?"),
                ),
              ),
              SizedBox(
                height: 20,
                child: Visibility(
                  visible: isLogin,
                  child: const CircularProgressIndicator(),
                ),
              ),
              SizedBox(
                height: 70,
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 5,
                      shadowColor: greyColor,
                      backgroundColor: blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      loginUser();
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> saveUserData() async {
  try {
    // Create a document in Firestore with phone number as document ID
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .set({
      'CharacterCount': 0,
      "uid": firebaseUser.uid,
      // Add other user data as needed
    });
  } catch (e) {
    Fluttertoast.showToast(msg: "Error saving user data: $e");
  }
}
