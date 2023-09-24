import 'package:chatapp/widgets/messagebubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chatmessages extends StatelessWidget {
  const Chatmessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedsuser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found'),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        final loadedmessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20, left: 13, right: 13),
          reverse: true, //the list will start from the bottom
          itemCount: loadedmessages.length,
          itemBuilder: (ctx, index) {
            final chatmessage = loadedmessages[index].data();
            final nextchatmessage = index + 1 < loadedmessages.length
                ? loadedmessages[index + 1].data()
                : null;
            final currentmessageuserid = chatmessage['userId'];
            final nextmessageuserid =
                nextchatmessage != null ? nextchatmessage['userId'] : null;
            final nextuserissame = nextmessageuserid == currentmessageuserid;

            if (nextuserissame) {
              return MessageBubble.next(
                  message: chatmessage['text'],
                  isMe: authenticatedsuser.uid == currentmessageuserid);
            } else {
              return MessageBubble.first(
                  userImage: chatmessage['userimage'],
                  username: chatmessage['username'],
                  message: chatmessage['text'],
                  isMe: authenticatedsuser.uid == currentmessageuserid);
            }
          },
        );
      },
    );
  }
}
