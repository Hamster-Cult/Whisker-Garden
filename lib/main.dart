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
        fontFamily: 'Dogica',
        scaffoldBackgroundColor: Color.fromARGB(192, 216, 216, 216)
      ),
      home: TitlePage(),
      );
  }
}


// loading page
// FIGURE OUT WHY THE HELL THE COLUMN ISN'T TAKING UP ALL THE SPACE!!! >:[
// it's not the gesture detector either :(
class TitlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LandingPage()));
        },
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset('assets/title-logo.png'),
              Image.asset('assets/title-mascot.png'),
              Text('tap to start'),
              ],
          ),
        ),
      );
  }
}

// default page
class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NavigationDashboard(),
          Stack(
            children: [
              Image.asset('assets/plants/01/two.png'), // find out how to connect the image displayed here from backend
              //add cat animation
            ],
          ),
          Center(child: LevelBar(level: 5, exp: 700)), // connect values to backend & make it
          Text("Write today's entry?",), // needs to be updated based on whether the user has logged mood or not
          GestureDetector( // button to write entry - this needs to be tied with the text above (showing only if need be)
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => EntryWritingPage()),
                      );
                    },
                    child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/entry-creation-button.png'),
                          SizedBox(width: 8),
                                ],
                              ),
                            ),
                    ),  
        ],
      ),
    );
  }
}

class ToDoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('This is the to-do page'),
    );
  }
}

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('This is the calendar page'),
    );
  }
}

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('This is the statistics page'),
    );
  }
}

class GardenShelfPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
              children: [
                  Text('You are viewing the garden!'),
                ],
      ),
    );
  }
}

// functional and transitional pages

class MoodLoggingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/okay-mood.png');
  }
}

class EntryWritingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
        EntryFormatting(
          entry:
              "Today I am feeling very Lorem ipsum odor amet, consectetuer adipiscing elit. Quam ullamcorper lacinia vehicula ornare lacinia interdum tincidunt cras. Est cras facilisis mauris mattis nascetur. Ligula ipsum bibendum himenaeos sed tortor nec. Cras dapibus ridiculus a nibh ridiculus interdum condimentum cursus. Interdum odio sapien vitae, mattis cursus finibus adipiscing massa. Parturient ac proin magna consequat adipiscing adipiscing fusce.\n\nLigula sem habitasse blandit lacinia eleifend sapien libero dolor cubilia. Cras ad cubilia est at fusce vivamus. Volutpat risus tortor duis enim lacinia per aliquam. Justo eleifend id neque purus; dapibus mus vestibulum et dis. Hac dui sollicitudin; luctus vel finibus rutrum nostra. Tristique dui tristique dapibus commodo turpis dolor placerat etiam. Vestibulum cursus urna facilisis interdum fringilla. Scelerisque egestas pellentesque ipsum nulla sem sapien orci torquent mauris.\n\nMalesuada neque taciti tempus maximus ex duis. Sociosqu fringilla porta mattis mattis in class. Ridiculus dui montes tortor porta sollicitudin. Ad dui odio ultrices elit suscipit. Torquent lacus penatibus eros vel nulla pretium inceptos accumsan cursus. Ex egestas netus ridiculus auctor ligula non aptent. Maximus risus vitae fringilla rhoncus nullam varius. Hendrerit inceptos pretium dis; neque mi consequat. Eleifend maximus quisque aptent urna sagittis tortor. Ornare lacus mi lobortis faucibus, faucibus quis elit faucibus.",
          mood: "Lorem Ipsum",
    );
  }
}




// Defining custom widgets


// Mood Entry is mostly done.
// - Figure out how to format with paragraph breaks
class EntryFormatting extends StatelessWidget {
  final today = DateTime.now();
  final DateFormat date = DateFormat('dd MMMM yyy');
  final DateFormat time = DateFormat('H:m');

  final String entry;
  final String mood;
  EntryFormatting({Key? key, required this.entry, required this.mood}) : super(key: key);
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "${time.format(today)} | Mood: $mood \n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
                ),
                Text(
                  entry,
                  style: TextStyle(fontSize: 25, letterSpacing: .6),
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


// update it so it dynamically resizes, animation, gesture detection is only on the pot(?)
class NavigationButton extends StatelessWidget {
  final String page;
  NavigationButton({Key? key, required this.page}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
                    //color: Colors.blue, // if you'd like to see the actual dimensions
                    margin: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 58,
                      height: 64,
                      child: Stack(
                        children: [
                          Image.asset('assets/navibar-unselected.png'),
                          Align(
                            alignment: Alignment(0, 0.8),
                            child: Text(page,
                            style: TextStyle(fontSize: 7, color: const Color.fromARGB(255, 255, 178, 182)))
                            )
                        ],
                      ),
                    ),
                  );
  }
}

// widget for navigation
class NavigationDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
            children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ToDoPage()),
                    );
                  },
                  child: NavigationButton(page: 'to-do')
                  ),
                  GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => GardenShelfPage()),
                    );
                  },
                  child: NavigationButton(page: 'garden')
                  ),
                  GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LandingPage()),
                    );
                  },
                  child: NavigationButton(page: 'today')
                  ),
                  GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CalendarPage()),
                    );
                  },
                  child: NavigationButton(page: 'calendar')
                  ),
                  GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => StatsPage()),
                    );
                  },
                  child: NavigationButton(page: 'stats')
                  ),
            ],
    );
  }
}

class LevelBar extends StatelessWidget {
  // need to figure out the math for the way level and exp work
  final int level;
  final int exp;
  LevelBar({Key? key, required this.level, required this.exp}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "LV $level:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Stack(
          children: [
            //idk if have to but maybe aligning the exp instead of layering it
            Container( // exp bar
              color: const Color.fromARGB(255, 255, 157, 170),
              child: SizedBox(
                width: exp / 10,
                height: 35,
              ),
            ),
            Container( // level border
         decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromARGB(192, 58, 58, 58),
            width: 3,),
          borderRadius: BorderRadius.circular(3),
         ),
         child: SizedBox(
          width: 200,
          height: 30,
          ),
        ),
        
          ],
        ),
        
      ],
    );
  }
}
