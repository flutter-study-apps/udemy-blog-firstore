import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  

  Post(
    {this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,}
  );

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    if (likes == 0) {
      return 0;
    }

    int count = 0;

    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });

    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
<<<<<<< HEAD
=======
  bool showHeart  = false;
>>>>>>> parent of f523068... Finished Real time messaging and comment
  int likeCount;
  Map likes;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });

  buildPostheader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return  ListTile(
          leading: CircleAvatar(
           backgroundImage: CachedNetworkImageProvider(user.photoUrl), 
           backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap:()=>print('something') ,
            child: Text(
              user.username, 
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: ()=>print('deleting post'),
            icon: Icon(Icons.more_vert), 
          ),
          
        );
      },
    );
  }

<<<<<<< HEAD
  buildPostImage(){
=======
  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      setState(() {
        likeCount += 1;
        isLiked = true;
        showHeart = true;
        likes[currentUserId] = true;
      });
      Timer(
        Duration(milliseconds: 500),
        (){
          setState(() {
            showHeart=false;
          });
        });
    }
  }

  buildPostImage() {
>>>>>>> parent of f523068... Finished Real time messaging and comment
    return GestureDetector(
      onDoubleTap: ()=>print('liking post'),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Image.network(mediaUrl),
          cachedNetworkImage(mediaUrl),
<<<<<<< HEAD
=======
          showHeart? 
          Animator(
            duration: Duration(
              milliseconds: 300,
            ),
            tween: Tween(begin: .08, end:1.4),
            curve: Curves.elasticOut,
            cycles: 0,
            builder: (anim)=>Transform.scale(
              scale: anim.value,
              child: Icon(Icons.favorite, size: 80, color: Colors.red,),
            ),
          )
           : Text(''),
>>>>>>> parent of f523068... Finished Real time messaging and comment
        ],
      ),
    );
  }

  buildPostFooter(){
    return Column(
      children: <Widget>[
<<<<<<< HEAD
         Row(
           mainAxisAlignment: MainAxisAlignment.start,
           children: <Widget>[
             Padding(padding: EdgeInsets.only(top: 40, left: 20)),
             GestureDetector(
               onTap: ()=>print('liking post'),
               child: Icon(
                 Icons.favorite_border,
                 size: 28,
                 color: Colors.pink,
               ),
             ),
             Padding(padding: EdgeInsets.only(right: 20)),
             GestureDetector(
               onTap: ()=>print('show comments'),
               child: Icon(
                 Icons.chat,
                 size: 28,
                 color: Colors.blue[900],
               ),
             ),
           ],
         ),
         Row(
           children: <Widget>[
             Container(
               margin: EdgeInsets.only(left:20),
=======
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => print('showing comments'),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
>>>>>>> parent of f523068... Finished Real time messaging and comment
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),
             )
           ],
         ),
         Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: <Widget>[
             Container(
               margin: EdgeInsets.only(left:20),
              child: Text(
                "$username likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),
             ),
             Expanded(child: Text(description)),
           ],
         ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostheader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
