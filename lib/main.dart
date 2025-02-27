import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whisker Garden',
      home: Scaffold(
        body: HomePage(),
        //style: TextStyle(fontFamily: 'Dogica')
        ),
      );
  }
}


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    
    switch (selectedIndex) {
      // figure out how to make the tile page a title page. it shouldn't be accessible through the navigation menu just there for now.
      case 0:
        page = TitlePage();
        break;
      case 1:
        page = LandingPage();
        break;
      case 2:
        page = GardenShelfPage();
        break;
      case 3:
        page = MoodLoggingPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Title'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Landing'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Garden'),
                  ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Today'),
                  ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              child: page,
            ),
          ),
        ],
      );
  }
}


class TitlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('You are on the title page!', style: TextStyle(fontFamily: 'Dogica'));
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          //put current plant image and cat animation ontop(?)
        ),
        // put level bar here

        // needs to be updated based on whether the user has logged mood or not
        Text("Write today's entry?"),

        ElevatedButton(
          onPressed: () {
            // access the page and set it to mood tracker
          },
          child: Text("Yes!"),
          ),
      ],
    );
  }
}

class GardenShelfPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('You are on the garden page!');
  }
}

class MoodLoggingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          GestureDetector(
    onTap: () {print('hi');},
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/okay-mood.png'), // Your custom icon here
          SizedBox(width: 8),
                ],
              ),
            ),
          ),  


        
          Text('You are on the mood logging page!',
          style: TextStyle(
            fontFamily: 'Dogica',
            ),
          ),
      ]
    );
  }
}
