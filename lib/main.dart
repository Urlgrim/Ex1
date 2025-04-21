import 'package:flutter/material.dart';
import 'news_screen.dart'; // We will create this file next

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
          primarySwatch: Colors.blue, // Or use ColorScheme.fromSeed
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Optional: Customize the AppBar theme to look like the example
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.lightBlue[300], // Light blue like example
            elevation: 0, // No shadow
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.white), // For back buttons etc.
          )
      ),
      home: const NewsScreen(), // Use the NewsScreen as the home page
    );
  }
}