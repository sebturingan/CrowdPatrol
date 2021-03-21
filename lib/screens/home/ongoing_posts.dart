import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crowd_patrol/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_patrol/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:crowd_patrol/screens/services/database.dart';

class OngoingList extends StatefulWidget {
  @override
  _OngoingListState createState() => _OngoingListState();
}

class _OngoingListState extends State<OngoingList> {

  final db = Firestore.instance;
  String _currentDocument;

  _finish() async {
    await db
    .collection('posts')
    .document(_currentDocument)
    .updateData({
      'responderStatus': 'Finished',
    });
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context); 

    return Scaffold(
      appBar: AppBar(
        title: Text('Ongoing Posts'),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
      ),
      body: StreamBuilder<User>(
        stream: DatabaseService(uid: user.uid).user,
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            User user = snapshot.data;

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/map.png'),
                  fit: BoxFit.cover
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: db.collection('posts').where('responderStatus', isEqualTo: 'Ongoing').where('responderID', arrayContains: user.uid).orderBy('timePosted', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {  
                    return ListView(
                      children: snapshot.data.documents.map((doc) {
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
                                ButtonBar(
                                  children: <Widget>[
                                    RaisedButton.icon(
                                      color: Colors.red,
                                      elevation: 0.0,
                                      icon: Icon(Icons.check),
                                      label: Text('Finish'),
                                      onPressed: () async {
                                        setState(() {
                                          _currentDocument = doc.documentID;
                                        });
                                        _finish();
                                        Navigator.pop(context);
                                      }
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                  return Container();
                  }
                },
              ),
            );
          } else {
            return Loading();
          }
        }
      ),
    );
  }
}