import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Color(0xffFAE1EB),
        centerTitle: true, 
        title: Text(
          'Catalogue',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
            ), // Add padding to the right
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
