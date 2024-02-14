import 'package:flutter/material.dart';
import 'package:tinytot_app/homepage.dart';
import 'color_schemes.g.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentication.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chooseplan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyTot',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return LoginSignupPage(); // Show login/signup page
            } else {
              // Fetch user data from Firestore
              final userDoc = FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid);
              return StreamBuilder<DocumentSnapshot>(
                stream: userDoc.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.active) {
                    if (userSnapshot.data == null ||
                        userSnapshot.data!['plan'] == "") {
                      return ChoosePlanPage(); // Show choose plan page
                    } else {
                      return HomeScreen(); // Show home page
                    }
                  }
                  return CircularProgressIndicator(); // Show loading spinner while waiting for user data
                },
              );
            }
          }
          return CircularProgressIndicator(); // Show loading spinner while waiting for auth state
        },
      ),
    );
  }
}
