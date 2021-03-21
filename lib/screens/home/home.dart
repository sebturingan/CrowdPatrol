import 'package:crowd_patrol/screens/home/rating_form.dart';
import 'package:crowd_patrol/screens/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:crowd_patrol/screens/services/database.dart';
import 'package:provider/provider.dart';
import 'package:crowd_patrol/screens/home/post_list.dart';
import 'package:crowd_patrol/models/post.dart';
import 'package:crowd_patrol/screens/home/add_post.dart';
import 'package:crowd_patrol/models/user.dart';
import 'package:crowd_patrol/screens/home/ongoing_posts.dart';
import 'package:crowd_patrol/screens/home/sender_list.dart';
import 'package:crowd_patrol/screens/home/pending_posts.dart';


class Home extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context); 
    
    return StreamProvider<List<Post>>.value(
      value: DatabaseService().posts,
      child: Scaffold(
        appBar: AppBar(
          title: Text('CrowdPatrol'),
          backgroundColor: Colors.blue[400],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.exit_to_app),
              label: Text('Logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/map.png'),
              fit: BoxFit.cover
            ),
          ),
          child: PostList(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddPost()));
          },
          elevation: 0.0,
          label: Text(
            'Add Post', 
            style: TextStyle(fontSize: 17.0),
          ),
          icon: Icon(Icons.add),
          backgroundColor: Colors.orange[400],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue[400],
          child: SizedBox(height: 50.0),
        ),
        drawer: Drawer(
          child: StreamBuilder<User>(
            stream: DatabaseService(uid: user.uid).user,
            builder: (context, snapshot) {
              if(snapshot.hasData){

                User user = snapshot.data;

                return ListView(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      currentAccountPicture: CircleAvatar(
                        maxRadius: 20.0, 
                        backgroundImage: AssetImage('assets/logo.png'), 
                        backgroundColor: Colors.white,              
                      ),
                      accountName: Text(
                        'CrowdPatrol',
                        style: TextStyle(color: Colors.white),
                      ),
                      accountEmail: Text(
                        'user.role',
                        style: TextStyle(color: Colors.black)
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          alignment: Alignment(1.0, 0),
                          image: AssetImage('assets/map.png'),
                          fit: BoxFit.cover, //BoxFit.fitHeight
                        )
                      ),
                    ),
                    ListTile(
                      title: Text('Rate'),
                      trailing: Icon(Icons.star),
                      onTap: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                          backgroundColor: Colors.blue[100],
                          context: context,
                          builder: (BuildContext context) => Container (
                            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                            height: 1000,
                            child: RatingsForm(),
                          ),
                        );
                      }
                    ),
                    ListTile(
                      title: Text('Your Posts'),
                      trailing: Icon(Icons.person),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SenderList()));
                      },
                    ),
                    ListTile(
                      title: Text('Pending Posts'),
                      trailing: Icon(Icons.access_time),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PendingList()));
                      },
                    ),
                    user.role == 'Responder'
                    ? ListTile(
                      title: Text('Ongoing Posts'),
                      trailing: Icon(Icons.location_on),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OngoingList()));
                      },
                      )
                    : SizedBox(height: 1.0),
                  ],
                );
              } else {
                return SizedBox(height: 1.0);
              }
            }
          ),
        ),
      ),
    );
  }
}