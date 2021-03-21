import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crowd_patrol/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_patrol/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crowd_patrol/screens/services/database.dart';
import 'package:url_launcher/url_launcher.dart';

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {

  final db = Firestore.instance;
  String _currentDocument;
  String _responderName;
  String _responderID;

  _updateData() async {
    await db
    .collection('posts')
    .document(_currentDocument)
    .updateData({'responderStatus': 'Ongoing'});
  }

  _setData() async {
    await db
    .collection('posts')
    .document(_currentDocument)
    .updateData({
      'responders': FieldValue.arrayUnion([_responderName]),
      'responderID': FieldValue.arrayUnion([_responderID])
    });
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context); 

    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('posts').where('status', isEqualTo: 'Approved').orderBy('timePosted', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data.documents.map((doc) {
              return StreamBuilder<User>(
                stream: DatabaseService(uid: user.uid).user,
                builder: (context, snapshot) {
                  if(snapshot.hasData){

                    User user = snapshot.data;

                    return Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Card(
                        elevation: 0.0,
                        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                '${doc.data['hashtag']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500, 
                                  fontStyle: FontStyle.italic,
                                  color: Colors.orange
                                ),
                              ),
                              subtitle: Text(DateFormat.yMMMd().add_jm().format(DateTime.parse(doc.data['timePosted'].toDate().toString())) + '''.
Posted by: ${doc.data['sender']}'''),
                              leading: Icon(
                                Icons.person_pin,
                                color: Colors.blue[400],
                                size: 45.0,
                              ), 
                            ),
                            Row(
                              children: <Widget> [
                                Card(
                                  elevation: 0.0,
                                  margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 6.0),
                                  child: Text(doc.data['details']),
                                ),
                              ],
                            ),
                            Container(
                              color: Colors.grey,
                              height: 350.0,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: Image.network(
                                      '${doc.data['image']}',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget> [
                                Card(
                                  elevation: 0.0,
                                  margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
                                  child: Text('Status: ${doc.data['status']}'),
                                ),
                              ],
                            ),
                            user.role == 'Responder' && doc.data['userUID'] != user.uid && doc.data['status'] != 'Finished'
                            ? ButtonBar(
                                children: <Widget>[
                                  RaisedButton.icon(
                                    color: Colors.red,
                                    elevation: 0.0,
                                    icon: Icon(Icons.location_on),
                                    label: Text('Respond'),
                                    onPressed: () async {
                                      if (await canLaunch(doc.data['geopoint'])) {
                                        await launch(doc.data['geopoint']);
                                      }
                                      setState(() {
                                        _currentDocument = doc.documentID;
                                      });
                                      setState(() {
                                        _responderName = user.firstName + ' ' + user.lastName;
                                        _responderID = user.uid;
                                      });
                                      _updateData();
                                      _setData();
                                    }
                                  ),
                                ],
                              )
                            : Padding(padding: EdgeInsets.only(bottom: 10.0)),
                            user.role == 'Guest'
                            ? Padding(padding: EdgeInsets.only(bottom: 10.0))
                            : Container(),
                          ],
                        ),
                      ) ,
                    );
                  } else {
                    return Loading();
                  }
                }
              );
            }).toList(),
          );
        } else {
          return Loading();
        }
      }
    );
  }
}