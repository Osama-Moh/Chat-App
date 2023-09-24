import 'package:chatapp/widgets/userimagepicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;
//this will create a firebase object that is managed by firebase SDK

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() {
    return _AuthscreenState();
  }
}

class _AuthscreenState extends State<Authscreen> {
  var _islogin = true;
  var _enteredemail = '';
  var _enteredpassword = '';
  var _enteredusername = '';
  File? _selectedimage;
  var _isuploading = false;

  final _formkey = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _formkey.currentState!.validate();

    if (!isValid || !_islogin && _selectedimage == null) {
      return;
    }

    _formkey.currentState!.save();

    try {
      setState(() {
        _isuploading = true;
      });
      if (_islogin) {
        final usercredential = await _firebase.signInWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);
      } else {
        final usercredential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);

        final storageref = FirebaseStorage.instance
            .ref()
            .child('user_images ')
            .child('${usercredential.user!.uid}.jpg');

        await storageref.putFile(_selectedimage!);
        final imageurl = await storageref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(usercredential.user!.uid)
            .set({
          'username': _enteredusername,
          'email': _enteredemail,
          'image_url': imageurl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
      setState(() {
        _isuploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 20, top: 30),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_islogin)
                            Userimagepicker(onpickimage: (pickedimage) {
                              _selectedimage = pickedimage;
                            }),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address/Username'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredemail = value!;
                            },
                          ),
                          if (!_islogin)
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty || value.trim().length < 4)
                                {
                                  return 'Please Enter at least 4 characters.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(label: Text('Username'),),
                              enableSuggestions: false,
                              onSaved: (value) {
                                _enteredusername = value!;
                              },
                            ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true, //hide content
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredpassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isuploading) const CircularProgressIndicator(),
                          if (!_isuploading)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              child: Text(_islogin ? 'Login' : 'Sign Up'),
                            ),
                          if (!_isuploading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _islogin = !_islogin;
                                });
                              },
                              child: Text(_islogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                        ],
                      ),
                    ),
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
