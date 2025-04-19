import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  final VoidCallback? onLoginPressed;
  const SignupPage({super.key, this.onLoginPressed});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String name = ''; // Changed from username to name
  String email = '';
  String password = '';
  String confirmPassword = '';

  String errorMessage = '';
  bool inputIsValid = true;
  bool _isLoading = false; // Add loading state

  Future<String?> getFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return '';
    }
  }

  Future<void> _signUp() async {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name in Firebase Auth
      await userCredential.user?.updateDisplayName(name);

      try {
        // Get current user from Firebase Auth
        User? user = FirebaseAuth.instance.currentUser;

        // Get current timestamp
        Timestamp createdAt = Timestamp.now();

        // Create the document data with name
        Map<String, dynamic> userData = {
          'createdAt': createdAt,
          'email': user?.email,
          'name': name, // Add name to Firestore document
          'profile_completed': 1,
          'fcm_token': await getFCMToken(),
          'uid': user?.uid,
          'accepted': 0,
        };

        // Add the document to Firestore
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user?.uid)
            .set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Account created successfully!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString()),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.message ?? 'An unknown error occurred.'),
        ),
      );
      setState(() {
        inputIsValid = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 60.0),
                  const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Create your account",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                        hintText:
                            "Full Name", // Changed from Username to Full Name
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: Colors.deepPurple.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.person)),
                    onChanged: (value) {
                      setState(() {
                        name = value; // Changed from username to name
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        confirmPassword = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 3, left: 3),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (name.isEmpty || // Add name validation
                              email.isEmpty ||
                              password.isEmpty ||
                              confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Please fill in all fields'),
                              ),
                            );
                            return;
                          } else {
                            _signUp();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ) // Show loader
                      : const Text(
                          "Sign up",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        if (widget.onLoginPressed != null) {
                          widget.onLoginPressed!();
                        }
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.deepPurple),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
