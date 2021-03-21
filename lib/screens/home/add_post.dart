import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crowd_patrol/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_patrol/models/user.dart';
import 'package:crowd_patrol/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:crowd_patrol/screens/services/database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:multiselect_formfield/multiselect_formfield.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {

  //geolocation reference
  Geolocator geolocator = Geolocator();

  //firestore instance
  final db = Firestore.instance;
  
  //active fields
  String sender;
  String details;
  File _image;
  String _uploadedFileURL;
  Position userLocation;
  List _hashtag;
  String _hashtagChoices;

  //controllers
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();

  //clear form
  clearForm() {
    setState(() {
      _nameController.text = "";
      _detailsController.text = "";
      _image = null;
      _uploadedFileURL = null;
    });
  }

  //get location
  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  //select an image via gallery or camera
  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      setState(() {
        _image = image;
      });
    });

    StorageReference storageReference = FirebaseStorage.instance.ref().child('images/${Path.basename(_image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  //form key
  final _formKey = GlobalKey<FormState>();

  //loading screen
  bool loading = false;

  //checkbox
  bool fireVal = false;
  bool floodVal = false;
  bool eqVal = false;
  bool lsVal = false;

  void initState() {
    super.initState();
    _hashtag = [];
    _hashtagChoices = '';
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context); 

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        title: Text('Add Post'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: StreamBuilder<User>(
          stream: DatabaseService(uid: user.uid).user,
          builder: (context, snapshot) {
            if(snapshot.hasData){

            User user = snapshot.data;

            //add post
            Future<void> addPost() async {
              await db.collection("posts").add({
                'sender': user.firstName + ' ' + user.lastName,
                'userUID': user.uid,
                'details': details,
                'timePosted': Timestamp.now(),
                'geopoint': "https://maps.google.com/maps?f=q&q="+userLocation.latitude.toString()+","+userLocation.longitude.toString(),
                'image': _uploadedFileURL,
                'hashtag': _hashtag,
                'status': 'Pending',
              }).then((documentReference) {
                print(documentReference.documentID);
                clearForm();
              }).catchError((e) {
                print(e);
              });
            }

            return Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  MultiSelectFormField(
                    autovalidate: false,
                    titleText: 'Choose Hashtag',
                    validator: (value) {
                      if (value == null || value.length == 0) {
                        return 'Please select one or more options';
                      }
                    },
                    dataSource: [
                      {
                        "display": "Fire",
                        "value": "Fire",
                      },
                      {
                        "display": "Flood",
                        "value": "Flood",
                      },
                      {
                        "display": "Landslide",
                        "value": "Landslide",
                      },
                      {
                        "display": "Power Outage",
                        "value": "Power Outage",
                      },
                      {
                        "display": "Rockslide",
                        "value": "Rockslide",
                      },
                    ],
                    textField: 'display',
                    valueField: 'value',
                    okButtonLabel: 'OK',
                    cancelButtonLabel: 'CANCEL',
                    // required: true,
                    hintText: 'Please choose one or more',
                    value: _hashtag,
                    onSaved: (value) {
                      if (value == null) return;
                      setState(() {
                        _hashtag = value;
                      });
                    },
                  ),
                  _image != null
                    ? Container(
                      height: 100,
                      child: Center(
                        child: Text('Image Uploaded.'),
                      )
                    )
                    : Container(),
                  _image == null
                    ? Container(
                        height: 100, 
                        child: Icon(
                          Icons.photo,
                          size: 120.0,
                          color: Colors.grey[400],
                        ),
                      )
                    : Container(),
                  IconButton(
                    icon: Icon(Icons.add_a_photo),
                    onPressed: () => chooseFile(),
                    iconSize: 40,
                  ),
                  TextFormField(
                    maxLines: 5,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter details';
                      }
                      if (value.trim() == "")
                        return "Only Space is Not Valid!!!";
                        return null;
                    },
                    onSaved: (value) {
                      details = value;
                    },
                    controller: _detailsController,
                    decoration: textInputDecoration.copyWith(hintText: 'Details about your situation'),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      RaisedButton(
                        elevation: 0.0,
                        color: Colors.blue[400],
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white), 
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            setState(() {
                              _hashtagChoices = _hashtag.toString();
                            });
                            _getLocation().then((value) {
                              setState(() {
                                userLocation = value;
                              });
                            });
                            addPost();
                            Navigator.pop(context);
                          }
                        }
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      RaisedButton(
                        elevation: 0.0,
                        color: Colors.red[400],
                        child: Text(
                          'Clear',
                          style: TextStyle(color: Colors.white), 
                        ),
                        onPressed: () {
                          clearForm();
                        }
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
              return Loading();
            }
          }
        ),
      ),
    );
  }
}
