import 'package:flutter/material.dart';
import 'homepage.dart'; // Import the home screen
import 'package:shared_preferences/shared_preferences.dart';

class AgeSelection extends StatefulWidget {
  @override
  _AgeSelectionState createState() => _AgeSelectionState();
}

class _AgeSelectionState extends State<AgeSelection> {
  int selectedAge = 0; // Default age (0-4)
  late SharedPreferences _prefs;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    if (!isFirstTime){
      _navigateToHome();
    }
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    isFirstTime = _prefs.getBool('isFirstTime') ?? true;
  }

  void _saveSelectedAge() {
    _prefs.setInt('selectedAge', selectedAge);
    _prefs.setBool('isFirstTime', false);
  }

  void _navigateToHome() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TinyTot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[


          Container(
          width: 150, // Adjust the width as needed
          height: 50, // Adjust the height as needed
          child:  ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedAge = 0; // Age 0-4
                });
                _saveSelectedAge();
                _navigateToHome();
              },

              child: Text('Age 0-4'),
            ),), SizedBox(height:14),
        Container(
          width: 150, // Adjust the width as needed
          height: 50, // Adjust the height as needed
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedAge = 1; // Age 4-8
                });
                _saveSelectedAge();
                _navigateToHome();
              },

              child: Text('Age 4-8'),
            ),), SizedBox(height:14),
            Container(
    width: 150, // Adjust the width as needed
    height: 50, // Adjust the height as needed
    child:  ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedAge = 2; // Age 8 and above
                });
                _saveSelectedAge();
                _navigateToHome();
              },

              child: Text('Age 8+'),
            ),),
          ],
        ),
      ),
    );
  }
}
