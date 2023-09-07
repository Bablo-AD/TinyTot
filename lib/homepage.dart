import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post_information.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String searchQuery = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shop')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Books...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ), // Pass the search query here
          Expanded(
            child: BookGrid(searchQuery: ""), // Pass the search query here
          ),
        ],
      ),
    );
  }
}
class BookGrid extends StatefulWidget {
  final String searchQuery;

  BookGrid({required this.searchQuery});

  @override
  State<BookGrid> createState() => _BookGridState();
}

class _BookGridState extends State<BookGrid> {
  String searchQuery = "";
  int selectedage = 0;
  late SharedPreferences _prefs;
  List<String> cartItems = [];

  void getStuff() async {
    _prefs = await SharedPreferences.getInstance();
    selectedage = _prefs.getInt('selectedAge') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    getStuff();
  }

  void addToCart(String product) {
    setState(() {
      if (!cartItems.contains(product)) {
        cartItems.add(product);
        //.setStringList('cartitems', cartItems);
      }

    });
  }

  void removeFromCart(String product) {
    setState(() {

        cartItems.remove(product);
       // _prefs.setStringList('cartitems', cartItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("products").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data!.docs;
              final filteredProducts = products
                  .where((product) => product["agetag"] == selectedage)
                  .toList();
              final filteredBooks = filteredProducts
                  .where(
                    (book) =>
                    book["name"].toString().toLowerCase().contains(searchQuery),
              )
                  .toList();

              if (filteredBooks.isEmpty) {
                return Center(child: Text("No products available"));
              }

              return ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  final name = book["name"];
                  final imageUrl = book["image"];
                  final price = book["price"];
                  final type = book["type"];
                  final agetag = book["agetag"];
                  final isSelected = cartItems.any((item) => item == name);

                  return Card(

                      child: ListTile(
                    title: Text(name),
                    subtitle: Text("\₹$price"),
                    leading: Image.network(
                      imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        if (isSelected) {
                          removeFromCart(name.toString());

                        } else {
                          addToCart(name.toString());
                        }
                      },
                      icon: Icon(isSelected ? Icons.check : Icons.add,color: isSelected ? Colors.red : Colors.redAccent,),
                    ),
                  ));
                },
              );
            },
          ),
        ),
        if (cartItems.isNotEmpty)
          FloatingActionButton.extended(label:Text("Proceed"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => UserDataPage(cartItems:cartItems,)),
              );
              // Implement logic to proceed with the selected items
            },
            icon: Icon(Icons.shopping_cart),
          ),
        SizedBox(height:20)
      ],
    );
  }
}
