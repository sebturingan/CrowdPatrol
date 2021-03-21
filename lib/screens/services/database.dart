import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_patrol/models/post.dart';
import 'package:crowd_patrol/models/user.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  
  //collection reference
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference postCollection = Firestore.instance.collection('posts');

  //update user data
  Future updateUserData(String firstName, String lastName, String role, String uid) async {
    return await userCollection.document(uid).setData({
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'uid': uid,
    });
  }

  //post list from snapshot
  List<Post> _postListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Post(
        sender: doc.data['sender'] ?? '',
        details: doc.data['details'] ?? '',
        timePosted: doc.data['timePosted'] ?? '',
        geopoint: doc.data['geopoint'] ?? '',
        image: doc.data['image'] ?? '',
        hashtag: doc.data['hashtag'] ?? '',
        status: doc.data['status'] ?? '',
        userUID: doc.data['userUID'] ?? '',
      );    
    }).toList();
  }

  //user data from snapshot
  User _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return User(
      uid: uid,
      firstName: snapshot.data['firstName'],
      lastName: snapshot.data['lastName'],
      role: snapshot.data['role'],
    );
  }

  //get post doc stream
  Stream<List<Post>> get posts {
    return postCollection.snapshots()
      .map(_postListFromSnapshot);
  }

  //get user doc stream
  Stream<User> get user {
    return userCollection.document(uid).snapshots()
      .map(_userDataFromSnapshot);
  }
}