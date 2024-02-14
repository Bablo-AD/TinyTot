import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinytot_app/homepage.dart';

class ChoosePlanPage extends StatefulWidget {
  @override
  _ChoosePlanPageState createState() => _ChoosePlanPageState();
}

class _ChoosePlanPageState extends State<ChoosePlanPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedPlan = 0;

  Future<void> _choosePlan(int plan) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'plan': plan,
      });

      // Navigate to a new page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Plan'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Plan 1: Choose 5 books'),
            trailing: _selectedPlan == 1 ? Icon(Icons.check) : null,
            onTap: () => _choosePlan(1),
          ),
          ListTile(
            title: Text('Plan 2: Choose 10 books'),
            trailing: _selectedPlan == 2 ? Icon(Icons.check) : null,
            onTap: () => _choosePlan(2),
          ),
          ListTile(
            title: Text('Plan 3: Choose 15 books'),
            trailing: _selectedPlan == 3 ? Icon(Icons.check) : null,
            onTap: () => _choosePlan(3),
          ),
        ],
      ),
    );
  }
}
