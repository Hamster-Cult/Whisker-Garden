import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // FOR DATE AND TIME

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
      // figure out how to make the title page a title page. it shouldn't be accessible through the
      // navigation menu just there for now.
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
    return MoodEntry(
      entry:
          "Today I am feeling very Lorem ipsum odor amet, consectetuer adipiscing elit. Quam ullamcorper lacinia vehicula ornare lacinia interdum tincidunt cras. Est cras facilisis mauris mattis nascetur. Ligula ipsum bibendum himenaeos sed tortor nec. Cras dapibus ridiculus a nibh ridiculus interdum condimentum cursus. Interdum odio sapien vitae, mattis cursus finibus adipiscing massa. Parturient ac proin magna consequat adipiscing adipiscing fusce.\n\nLigula sem habitasse blandit lacinia eleifend sapien libero dolor cubilia. Cras ad cubilia est at fusce vivamus. Volutpat risus tortor duis enim lacinia per aliquam. Justo eleifend id neque purus; dapibus mus vestibulum et dis. Hac dui sollicitudin; luctus vel finibus rutrum nostra. Tristique dui tristique dapibus commodo turpis dolor placerat etiam. Vestibulum cursus urna facilisis interdum fringilla. Scelerisque egestas pellentesque ipsum nulla sem sapien orci torquent mauris.\n\nMalesuada neque taciti tempus maximus ex duis. Sociosqu fringilla porta mattis mattis in class. Ridiculus dui montes tortor porta sollicitudin. Ad dui odio ultrices elit suscipit. Torquent lacus penatibus eros vel nulla pretium inceptos accumsan cursus. Ex egestas netus ridiculus auctor ligula non aptent. Maximus risus vitae fringilla rhoncus nullam varius. Hendrerit inceptos pretium dis; neque mi consequat. Eleifend maximus quisque aptent urna sagittis tortor. Ornare lacus mi lobortis faucibus, faucibus quis elit faucibus.",
      mood: "Lorem Ipsum",
    );
  }
}

// Mood Entry is mostly done.
// - Figure out how to format with paragraph breaks
class MoodEntry extends StatelessWidget {
  final today = DateTime.now();
  final DateFormat date = DateFormat('dd MMMM yyy');
  final DateFormat time = DateFormat('H:m');

  final String entry;
  final String mood;
  MoodEntry({Key? key, required this.entry, required this.mood}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          // entry space around the page
          margin: const EdgeInsets.only(top: 30, bottom: 30, right: 30, left: 60),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            // background styling
            color: Color.fromARGB(255, 185, 163, 192),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          // height: 10,
          child: Align(
            alignment: Alignment.topLeft,
            child: ListView(
              children: [
                Text(
                  date.format(today),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "${time.format(today)} | Mood: $mood \n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27, color: Colors.black),
                ),
                Text(
                  entry,
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
