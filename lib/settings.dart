import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userdatapage.dart';
import 'chooseplan.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _appVersion = 'v0.0.1';
  String _address = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    // Navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Change Plan'),
            onTap: () {
              // Navigate to edit user data page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChoosePlanPage()),
              );
            },
          ),
          ListTile(
            title: Text('Edit User Data'),
            onTap: () {
              // Navigate to edit user data page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditUserDataPage()),
              );
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'TinyTot',
                applicationVersion: _appVersion,
                applicationIcon: Icon(Icons.info),
                children: <Widget>[
                  Text('Spreading knowledge'),
                ],
              );
            },
          ),
          OutlinedButton(
            onPressed: _signOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.logout),
                SizedBox(
                    width:
                        8.0), // Add some spacing between the icon and the text
                Text("Log out"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
