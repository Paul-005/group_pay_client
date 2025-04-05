import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentAdminCodeEntry extends StatefulWidget {
  const StudentAdminCodeEntry({
    Key? key,
  }) : super(key: key);

  @override
  State<StudentAdminCodeEntry> createState() => _StudentAdminCodeEntryState();
}

class _StudentAdminCodeEntryState extends State<StudentAdminCodeEntry> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Join a Group',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Enter Admin Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter the 6-digit code provided by your instructor',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => Container(
                      width: 45,
                      height: 55,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        onChanged: (value) {
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade800,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: Colors.indigo.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      //disable button
                      setState(() {
                        _isVerifying = true;
                        _errorMessage = null;
                      });

                      String adminCode = _controllers.map((c) => c.text).join();

                      if (adminCode.length != 6) {
                        setState(() {
                          _errorMessage =
                              'Please enter the complete 6-digit code.';
                          _isVerifying = false;
                        });
                        return;
                      }

                      try {
                        // Reference to the 'groups' collection
                        CollectionReference groups =
                            FirebaseFirestore.instance.collection('groups');

                        // Check if the document with the adminCode exists
                        DocumentSnapshot groupDoc =
                            await groups.doc(adminCode).get();

                        if (groupDoc.exists) {
                          // Get the admin's UID from the group document
                          String adminUid = groupDoc['admin'];

                          // Reference to the 'admins' collection
                          CollectionReference admins =
                              FirebaseFirestore.instance.collection('admin');

                          // Get current user from Firebase Auth
                          User? user = FirebaseAuth.instance.currentUser;

                          // Get current timestamp
                          Timestamp createdAt = Timestamp.now();

                          // Create a new student request object
                          Map<String, dynamic> studentRequest = {
                            'email': user?.email,
                            'uid': user?.uid,
                            'name': user?.displayName,
                            'createdAt': createdAt,
                          };

                          // Update the admin's document to include the new student request
                          await admins.doc(adminUid).update({
                            'student_requests':
                                FieldValue.arrayUnion([studentRequest]),
                          });

                          // Update profile_completed status in students collection to 2
                          //Also update adminCode in students collection
                          await FirebaseFirestore.instance
                              .collection('students')
                              .doc(user?.uid)
                              .update({
                            'profile_completed': 2,
                            'adminCode': adminCode,
                          });

                          setState(() {
                            _isVerifying = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Code verified successfully!'),
                            ),
                          );
                        } else {
                          // If the group doesn't exist, show an error message
                          setState(() {
                            _errorMessage = 'Invalid admin code.';
                            _isVerifying = false;
                          });
                          return;
                        }
                      } catch (e) {
                        setState(() {
                          _errorMessage =
                              'An error occurred. Please try again.'; //e.toString();
                          _isVerifying = false;
                        });
                      } finally {
                        setState(() {
                          _isVerifying = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isVerifying
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Verify Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Need Help?',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          'Ask your instructor for the 6-digit admin code. This code is required to join their group.',
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Need help?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
