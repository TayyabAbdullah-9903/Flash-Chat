import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashchat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:flutter/services.dart';

final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  static const String id = '/chatscreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgcontroler = TextEditingController();

  late User loggedinUser;
  final _firestore = FirebaseFirestore.instance;
  String message = '';
  DateTime timefield = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    getcurrentuser();
  }

  void getcurrentuser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
        print(loggedinUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  //Implement logout functionality
                  _auth.signOut();
                  Navigator.pushNamed(context, WelcomeScreen.id);
                }),
          ],
          title: Text('⚡️Chat'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder(
                  stream: _firestore
                      .collection('messages')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.lightBlueAccent,
                          ),
                        ),
                      );
                    }
                    final messages = snapshot.data?.docs;
                    List<messagebubble> messageslist = [];
                    for (var message in messages!) {
                      final messagetext = message.data()['text'];
                      final messagesender = message.data()['sender'];
                      final messagetime = message.data()['time'];
                      final messagewidget = messagebubble(
                          messagesender, messagetext, loggedinUser.email);
                      messageslist.add(messagewidget);
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        children: messageslist,
                      ),
                    );
                  }),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: msgcontroler,
                        onChanged: (value) {
                          message = value;
                          timefield = DateTime.now();
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        msgcontroler.clear();
                        _firestore.collection('messages').add({
                          'sender': loggedinUser.email,
                          'text': message,
                          'time': timefield
                        });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class messagebubble extends StatelessWidget {
  final String text;
  final String sender;
  final String? loggedin;

  messagebubble(this.sender, this.text, this.loggedin);

  @override
  Widget build(BuildContext context) {
    if (sender == loggedin) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
            SizedBox(
              height: 2,
            ),
            Material(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30)),
              elevation: 5,
              color: Colors.green,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              sender,
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
            SizedBox(
              height: 2,
            ),
            Material(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(0)),
              elevation: 5,
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
