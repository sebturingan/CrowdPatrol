import 'package:crowd_patrol/screens/services/database.dart';
import 'package:crowd_patrol/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:crowd_patrol/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_patrol/models/user.dart';
import 'package:provider/provider.dart';

class RatingsForm extends StatefulWidget {
  @override
  _RatingsFormState createState() => _RatingsFormState();
}

class _RatingsFormState extends State<RatingsForm> {

  final db = Firestore.instance;

  final _formKey = GlobalKey<FormState>();

  int _rating = 1;
  String name;
  String feedback; 
  final _feedbackController = TextEditingController();  

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context); 

    return StreamBuilder<User>(
      stream: DatabaseService(uid: user.uid).user,
      builder: (context, snapshot) {
        if(snapshot.hasData){

          User user = snapshot.data;

          //add rating
          Future<void> addRating() async {
            await db.collection("ratings").add({
              'rating': _rating,
              'name': user.firstName + ' ' + user.lastName,
              'feedback': feedback,
              'timestamp': DateTime.now(),
            }).then((documentReference) {
              print(documentReference.documentID);
            }).catchError((e) {
              print(e);
            });
          }

          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'Give rating and feedback.',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  maxLines: 5,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter feedback';
                    }
                    if (value.trim() == "")
                      return "Only Space is Not Valid!!!";
                      return null;
                  },
                  onSaved: (value) {
                    feedback = value;
                  },
                  controller: _feedbackController,
                  decoration: textInputDecoration.copyWith(hintText: 'Feedback'),
                ),
                SizedBox(height: 20.0),
                Slider(
                  inactiveColor: Colors.orange[400],
                  value: (_rating ?? 1).toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (val) => setState(() => _rating = val.round()),
                ), 
                Container(
                  child: Text(
                    '$_rating out of 5',
                    style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                  color: Colors.blue[400],
                  child: Text(
                    'Rate',
                    style: TextStyle(color: Colors.white), 
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      addRating();
                      Navigator.pop(context);
                    }
                  } 
                ),
              ],
            )
          );
        } else {
          return Loading();
        }
      }
    );
  }
}
