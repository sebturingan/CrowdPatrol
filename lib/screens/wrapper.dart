import 'package:crowd_patrol/models/user.dart';
import 'package:crowd_patrol/screens/authenticate/authenticate.dart';
import 'package:crowd_patrol/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context); 

    //return either auth or home depending on the state of auth
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}