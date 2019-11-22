import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // createUser();
    // updateUser();
    deleteUser();
  }

  createUser() async {
    usersRef.document("fdfdfd").setData({
      "username": "Jeff",
      "postCount": 3,
      "isAdmin": false,
    });
  }

  updateUser() async{
    final DocumentSnapshot doc = await usersRef.document("fdfdfd").get();

    if (doc.exists){
      doc.reference.updateData({
        "username": "Janjeff",
        "postCount": 8,
        "isAdmin": false,
      });
    }
  }

  deleteUser()async{ 
    final doc = await usersRef.document("fdfdfd").get();

  if (doc.exists){
    usersRef.document("fdfdfd").delete();
  }

    // usersRef.document("fdfdfd").delete();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      // body: circularProgress(),
      // body: linearProgress(),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        //builder tells how are we going to display the snapshot data
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children = snapshot.data.documents
              .map((doc) => Text(doc['username']))
              .toList();
          return Container(
            child: ListView(
              children: children,
            ),
          );

 
        },
      ),
    );
  }
}
