import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  

  File file;
  bool isUploading = false;
  String postId = Uuid().v4(); //for unique Id

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                  child: Text("Photo with Camera"), onPressed: handleTakePhoto),
              SimpleDialogOption(
                  child: Text("Image from Gallery"),
                  onPressed: handleChooseFromGallery),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
              padding: EdgeInsets.only(top: 20),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: Text(
                  "Upload Image",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                color: Colors.deepOrange,
                // onPressed:null,
                onPressed: () => selectImage(context),
              )),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage()async{
    final tempDir  = await getTemporaryDirectory();
    final path =  tempDir.path; //get the temporary directory of your app
    Im.Image imageFile =  Im.decodeImage(file.readAsBytesSync()); // reading image and put in image variable
    final compressedImageFile = File('$path/img_$postId.jpg')
    ..writeAsBytesSync(Im.encodeJpg(imageFile, quality:10));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile)async{
    StorageUploadTask uploadTask =  storageRef.child("post_$postId.jpg")  //implements resumable uploads of file in firebase storage
    .putFile(imageFile);
    StorageTaskSnapshot storageSnap =  await uploadTask.onComplete; //FIRStorageTaskSnapshot represents an immutable view of a task.
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

    createPostInFirestore(
        {String mediaUrl, String location, String description}) {
      postsRef
          .document(widget.currentUser.id)
          .collection("userPosts")
          .document(postId)
          .setData({
        "postId": postId,
        "ownerId": widget.currentUser.id,
        "username": widget.currentUser.username,
        "mediaUrl": mediaUrl,
        "description": description,
        "location": location,
        "timestamp": timestamp,
        "likes": {},
      });
    }
  handleSubmit() async{
    setState(() {
      isUploading=true;
    });
    
    await compressImage();  //compress imge

    //upload the post
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );

    //Reset and clear previous values
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4(); //reset the ID for the new assigned post
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: isUploading==null? null : ()=>handleSubmit(),
              child: Text(
                "Post",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ))
        ],
      ),  
      body: ListView(
        children: <Widget>[
          isUploading ? LinearProgressIndicator() : Text(""),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * .8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                   CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
                width: 250,
                child: TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                    hintText: "Write a caption...",
                    border: InputBorder.none,
                  ),
                )),
          ),
          Divider(),
           ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
           Container(
              width: 20,
              height: 100,
              alignment: Alignment.center,
              child: RaisedButton.icon(
                label: Text(
                  "use Current Location",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: Colors.blue,
                onPressed: getUserLocation,
                icon: Icon(Icons.my_location, color: Colors.white),
              ),
            ),
         
        ],
      ),
    );
  }

  getUserLocation()async{
     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
     List<Placemark> placemarks =  await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
  
    Placemark placemark = placemarks[0];

    String  completeAddress = ' #${placemark.subThoroughfare} ${placemark.thoroughfare} ${placemark.locality} ${placemark.subAdministrativeArea} ${placemark.country} '; 
    locationController.text = completeAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
