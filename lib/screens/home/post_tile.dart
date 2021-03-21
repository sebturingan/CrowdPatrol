import 'package:flutter/material.dart';
import 'package:crowd_patrol/models/post.dart';
import 'package:intl/intl.dart';
import 'package:crowd_patrol/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:crowd_patrol/screens/services/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crowd_patrol/shared/loading.dart';

class PostTile extends StatelessWidget {

  _updateData(selectedDoc) async {
    await db
    .collection('posts')
    .document(selectedDoc)
    .updateData({'status': 'Ongoing'});
  }

  final db = Firestore.instance;

  final User user;
  final Post post;
  PostTile({ this.post, this.user });

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context); 

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
                      '${post.hashtag}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500, 
                        fontStyle: FontStyle.italic,
                        color: Colors.orange
                      ),
                    ),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(DateTime.parse(post.timePosted.toDate().toString())) + '''.
Posted by: ${post.sender}'''),
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
                        child: Text(post.details),
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
                            '${post.image}',
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
                        child: Text('Status: ${post.status}'),
                      ),
                    ],
                  ),
                  user.role == 'Responder' && post.userUID != user.uid
                  ? ButtonBar(
                      children: <Widget>[
                        RaisedButton.icon(
                          color: Colors.red,
                          elevation: 0.0,
                          icon: Icon(Icons.location_on),
                          label: Text('Respond'),
                          onPressed: () async {
                            if (await canLaunch(post.geopoint)) {
                              await launch(post.geopoint);
                            }
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
  }

  Future<bool> updateDialog(BuildContext context, selectedDoc) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Respond'),
          content: const Text('This item is no longer available'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateData(selectedDoc);
              },
            ),
          ],
        );
      },
    );
  }

}