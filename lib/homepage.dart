import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post_information.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  final int maxBooks;
  HomeScreen({required this.maxBooks});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _children = [
    HomePage(),
    SettingsPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TinyTot')),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  @override
  Widget build(BuildContext context) {
    return Column(
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
          child:
              BookGrid(searchQuery: searchQuery), // Pass the search query here
        ),
      ],
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
            stream:
                FirebaseFirestore.instance.collection("products").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              List<dynamic> filteredBooks = [];

              if (snapshot.hasData && snapshot.data != null) {
                final products = snapshot.data!.docs;
                final filteredProducts = products
                    .where((product) => product["agetag"] == selectedage)
                    .toList();
                filteredBooks = filteredProducts
                    .where(
                      (book) => book["name"]
                          .toString()
                          .toLowerCase()
                          .contains(widget.searchQuery),
                    )
                    .toList();
              }

              if (filteredBooks.isEmpty) {
                return Center(child: Text("No products available"));
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // number of items in a row
                  childAspectRatio: 5 / 5, // ratio of item width to item height
                  crossAxisSpacing: 10, // spacing between items horizontally
                  mainAxisSpacing: 10, // spacing between items vertically
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  final name = book["name"];
                  final imageUrl = book["image"];
                  final price = book["price"];
                  final type = book["type"];
                  final agetag = book["agetag"];
                  bool isSelected = cartItems.any((item) => item == name);

                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected =
                              !isSelected; // toggle the isSelected state
                          if (isSelected) {
                            addToCart(name);
                          } else {
                            removeFromCart(name);
                          }
                        });
                      },
                      child: Card(
                        color: isSelected
                            ? Theme.of(context).highlightColor
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 18.0 / 11.0,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    name,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text("Stock $price"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              );
            },
          ),
        ),
        if (cartItems.isNotEmpty)
          FloatingActionButton.extended(
            label: Text("Proceed"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => UserDataPage(
                          cartItems: cartItems,
                        )),
              );
              // Implement logic to proceed with the selected items
            },
            icon: Icon(Icons.shopping_cart),
          ),
        SizedBox(height: 20)
      ],
    );
  }
}
