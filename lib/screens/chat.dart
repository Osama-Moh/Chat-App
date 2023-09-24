import 'package:chatapp/widgets/chatmessages.dart';
import 'package:chatapp/widgets/newmessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {

  void setuppushnotifications () async 
  {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    final token = await fcm.getToken();       //this yields the adrress of the device
    fcm.subscribeToTopic('chat');
  } 


  @override
  void initState() {
    super.initState();
    setuppushnotifications();
  }
  //it is not recommended to use async with initstate

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter chat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(child: Chatmessages()),
          SizedBox(
            height: 10,
          ),
          Newmessage(),
        ],
      ),
    );
  }
}
