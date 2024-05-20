import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:text_to_speech/screens/loginpage.dart';

import '../utils/colors/colors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

final _formKey = GlobalKey<FormState>();

TextEditingController emailController = TextEditingController();
TextEditingController passController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController ageController = TextEditingController();

// adduser() async {
//   User? firebaseUser = FirebaseAuth.instance.currentUser;
//   FirebaseFirestore.instance.collection("profiles").doc(firebaseUser?.uid).set({
//     "name": nameController.text,
//     "age": ageController.text,
//     "uid": firebaseUser?.uid,
//   }).then(
//     (value) => Fluttertoast.showToast(msg: "Registered!").onError(
//       (error, stackTrace) => Fluttertoast.showToast(msg: "$error"),
//     ),
//   );
// }

void registerUser(BuildContext context) async {
  try {
    // ignore: unused_local_variable
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passController.text,
        )
        .then(
          (value) => {
            Fluttertoast.showToast(msg: "User Registered!"),
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => const LoginPage()),
                )),
          },
        );
  } catch (e) {
    Fluttertoast.showToast(msg: "$e");
  }
}

class _SignupPageState extends State<SignupPage> {
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
                "assets/images/4957136.jpg",
                height: 400,
                width: 500,
                fit: BoxFit.cover,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Register ",
                    style: TextStyle(
                        fontSize: 30,
                        color: greyColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Yourself",
                    style: TextStyle(
                        fontSize: 30,
                        color: blueColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Name field cant be empty";
                    } else {
                      return null;
                    }
                  },
                  controller: nameController,
                  autofocus: false,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 4, color: greyColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: blueColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Username",
                    hintText: "Enter Your Name",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Age field cant be empty";
                    } else {
                      return null;
                    }
                  },
                  controller: ageController,
                  autofocus: false,
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
                    hintText: "Enter Your Age",
                    labelText: "Age",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email field cant be empty";
                    } else {
                      return null;
                    }
                  },
                  controller: emailController,
                  autofocus: false,
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
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password field cant be empty";
                    } else if (value.length < 6) {
                      return "Password must contains minimum 6 Characters";
                    }
                    return null;
                  },
                  controller: passController,
                  obscureText: true,
                  autofocus: false,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 4, color: greyColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: blueColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: "Password",
                    hintText: "Enter Your Password",
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      registerUser(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const SignupPage(),
                      //   ),
                      // );
                      // adduser();
                    }
                  },
                  child: const Text(
                    "Signup",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
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
