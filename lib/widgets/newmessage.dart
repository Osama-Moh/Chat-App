import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Newmessage extends StatefulWidget {
  const Newmessage({super.key});

  @override
  State<Newmessage> createState() {
    return _NewmessageState();
  }
}

class _NewmessageState extends State<Newmessage> {

  final _messagecontroller = TextEditingController();

  @override
  void dispose() {
    _messagecontroller.dispose();
    super.dispose();
  }
  void _submitmessage () async
  {
    final enteredmessage = _messagecontroller.text;

    if (enteredmessage.trim().isEmpty)
    {
      return;
    }
    FocusScope.of(context).unfocus();   //this will close the keyboard
    _messagecontroller.clear();     //this will clear the textinput field

    final user = FirebaseAuth.instance.currentUser!;
    final userdata = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredmessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userdata.data()!['username'],
      'userimage': userdata.data()!['image_url'],
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
              controller: _messagecontroller,
            ),
          ),
          IconButton(
            onPressed: _submitmessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
