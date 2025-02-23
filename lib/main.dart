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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey, brightness: Brightness.light),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 60,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      // figure out how to make the title page a title page. it shouldn't be accessible through the navigation menu just there for now.
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
              NavigationRailDestination(icon: Icon(Icons.home), label: Text('Title')),
              NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Landing')),
              NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Garden')),
              NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Today')),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
        ),
        Expanded(child: Container(child: page)),
      ],
    );
  }
}

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('You are on the title page!');
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
  const GardenShelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('You are on the garden page!');
  }
}

class MoodLoggingPage extends StatelessWidget {
  const MoodLoggingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return Text('You are on the mood logging page!');
    return Scaffold(
      body: Center(
        child: Container(
          // entry spacing
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            // styling
            color: Color.fromARGB(255, 185, 163, 192),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          // height: 10,
          child: Align(
            alignment: Alignment.topLeft,
            child: ListView(
              children: [
                const Text(
                  '20 February 2025',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Today I am feeling very Lorem ipsum odor amet, consectetuer adipiscing elit. Quam ullamcorper lacinia vehicula ornare lacinia interdum tincidunt cras. Est cras facilisis mauris mattis nascetur. Ligula ipsum bibendum himenaeos sed tortor nec. Cras dapibus ridiculus a nibh ridiculus interdum condimentum cursus. Interdum odio sapien vitae, mattis cursus finibus adipiscing massa. Parturient ac proin magna consequat adipiscing adipiscing fusce.\n\nLigula sem habitasse blandit lacinia eleifend sapien libero dolor cubilia. Cras ad cubilia est at fusce vivamus. Volutpat risus tortor duis enim lacinia per aliquam. Justo eleifend id neque purus; dapibus mus vestibulum et dis. Hac dui sollicitudin; luctus vel finibus rutrum nostra. Tristique dui tristique dapibus commodo turpis dolor placerat etiam. Vestibulum cursus urna facilisis interdum fringilla. Scelerisque egestas pellentesque ipsum nulla sem sapien orci torquent mauris.\n\nMalesuada neque taciti tempus maximus ex duis. Sociosqu fringilla porta mattis mattis in class. Ridiculus dui montes tortor porta sollicitudin. Ad dui odio ultrices elit suscipit. Torquent lacus penatibus eros vel nulla pretium inceptos accumsan cursus. Ex egestas netus ridiculus auctor ligula non aptent. Maximus risus vitae fringilla rhoncus nullam varius. Hendrerit inceptos pretium dis; neque mi consequat. Eleifend maximus quisque aptent urna sagittis tortor. Ornare lacus mi lobortis faucibus, faucibus quis elit faucibus.",
                  style: TextStyle(fontSize: 25, color: Colors.black, letterSpacing: .6),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Date and Entry are currently hard coded, this is used to modularise the code for maintainabillity, will be implemented after figuring out the general layout
class MoodEntry extends StatelessWidget {
  // const MoodEntry({super.key, required this.date, this.entry}) : super(key: key);
  final DateTime date;
  final String entry;
  const MoodEntry({Key? key, required this.date, required this.entry}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
