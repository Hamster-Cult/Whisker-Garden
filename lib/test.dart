import 'package:flutter/material.dart';
import 'client.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test',
      home: Scaffold(
        body: TestPage()
      )
    );

  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late Future<Album> _exp = getEXP();

  @override
  void initState() {
    super.initState();
    _exp = getEXP();
  }

  @override
  Widget build(BuildContext context) {
    return 
                    FutureBuilder<Album>(
                      future: _exp,
                      builder: (context, snapshot) {
                        // Check if the Future is still loading
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();  // Show a loading indicator
                        } 
                        // If an error occurred or the Future is done
                        else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } 
                        // If the Future completed successfully
                        else if (snapshot.hasData) {
                          return Text('${snapshot.data!.exp}');  // Display the result
                        } else {
                          return Text('No data');
                        }
                      },
                   );
  }
  }

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('data'),);
  }
}