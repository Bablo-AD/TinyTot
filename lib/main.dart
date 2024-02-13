import 'package:flutter/material.dart';
import 'package:tinytot_app/homepage.dart';
import 'age_selectionscreen.dart';
import 'color_schemes.g.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentication.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              return HomeScreen(); // Show home page
            }
          }
          return CircularProgressIndicator(); // Show loading spinner while waiting for auth state
        },
      ),
    );
  }
}
