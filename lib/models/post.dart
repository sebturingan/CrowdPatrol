import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

  final String sender;
  final String details;
  final Timestamp timePosted;
  final String geopoint;
  final String image;
  final String hashtag;
  final String status;
  final String userUID;

  Post({ this.sender, this.details, this.timePosted, this.geopoint, this.image, this.hashtag, this.status, this.userUID });

}