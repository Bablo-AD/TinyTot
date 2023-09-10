import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';

class UserDataPage extends StatefulWidget {
  final List<String> cartItems;
  UserDataPage({required this.cartItems});

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  void loader() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      addressController.text = prefs.getString('address') ?? "";
      phoneNumberController.text = prefs.getString('phonenumber') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    loader();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postal Information'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: 'Address on top of the parcel',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the address';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                hintText: "To contact during the postal",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Form is valid, process and save user data here
            final address = addressController.text;
            final phoneNumber = phoneNumberController.text;

            // You can now use 'address' and 'phoneNumber' as needed

            final prefs = await SharedPreferences.getInstance();
            prefs.setString('address', address);
            prefs.setString('phonenumber', phoneNumber);
            await FirebaseFirestore.instance.collection('orders').add({
              'address': address,
              'phonenumber': phoneNumber,
              'cart': widget.cartItems,
              'dispatch': false
              // Add other fields as needed
            });
            // Navigate to the next page or perform other actions
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );

            // Show a snackbar on the home page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order placed'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        label: Text('Next'),
        icon: Icon(Icons.arrow_right_alt),
      ),
    );
  }
}
