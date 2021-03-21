import 'package:crowd_patrol/screens/authenticate/sign_in_anon.dart';
import 'package:crowd_patrol/screens/authenticate/sign_in_ep.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/map.png'),
          fit: BoxFit.cover
        ),
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            Image.asset('assets/logo.png'),
            FlatButton.icon(
              icon: Icon(
                Icons.person_pin, 
                color: Colors.white,
              ),
              label: Text(
                'Sign in as a Responder',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 20,
                ),
              ),
              color: Colors.blue[400],
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignInEP()));
              },
            ),
            FlatButton.icon(
              icon: Icon(
                Icons.person_pin, 
                color: Colors.white,
              ),
              label: Text(
                'Sign in as a Sender',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 20,
                ),
              ),
              color: Colors.blue[400],
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignInAnon()));
              },
            ),
          ],
        ),
      ),
    );
  }
}