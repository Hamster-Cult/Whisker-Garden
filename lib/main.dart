import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time
import 'client.dart'; // Handels fetching data

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
      home: Scaffold(body: TitlePage()),
      );
  }
}


// loading page
class TitlePage extends StatelessWidget {
  const TitlePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LandingPage()));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
                    Expanded(child: Image.asset('assets/logo.png')),
                    Text('tap to start'),
                  ] ,
                ),
      );
  }
}

// default page
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NavigationDashboard(),
          Stack(
            children: [
              Image.asset('assets/plants/01/two.png'), // find out how to connect the image displayed here from backend
              //add cat animation
            ],
          ),
          Align(alignment: Alignment.center, child: LevelBar()),
          Text("Write today's entry?",), // needs to be updated based on whether the user has logged mood or not
          GestureDetector( // button to log mood - this needs to be tied with the text above (showing only if need be)
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
  const ToDoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NavigationDashboard(),
          LevelBar(),
          Text('This is the to-do page'),
        ],
      ),
    );
  }
}

// working on this it doesn't work rn
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NavigationDashboard(),
          LevelBar(),
          Text('This is the calendar page'),
          EntryFormatting(
                  entry: "This is an example of an entry",
                  mood: "Lorem Ipsum",
                    ),
        ],
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NavigationDashboard(),
          LevelBar(),
          Text('This is the statistics page'),
        ],
      ),
    );
  }
}

class GardenShelfPage extends StatelessWidget {
  const GardenShelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NavigationDashboard(),
          LevelBar(),
          Text('You are viewing the garden!'),
        ],
      ),
    );
  }
}

// functional and transitional pages

class MoodLoggingPage extends StatelessWidget {
  const MoodLoggingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/okay-mood.png');
  }
}

class ViewEntryPage extends StatelessWidget {
  const ViewEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
              Scaffold(
                body: EntryFormatting(
                  entry: // access a specific entry from backend
                      "Today I am feeling very Lorem ipsum odor amet, consectetuer adipiscing elit. Quam ullamcorper lacinia vehicula ornare lacinia interdum tincidunt cras. Est cras facilisis mauris mattis nascetur. Ligula ipsum bibendum himenaeos sed tortor nec. Cras dapibus ridiculus a nibh ridiculus interdum condimentum cursus. Interdum odio sapien vitae, mattis cursus finibus adipiscing massa. Parturient ac proin magna consequat adipiscing adipiscing fusce.\n\nLigula sem habitasse blandit lacinia eleifend sapien libero dolor cubilia. Cras ad cubilia est at fusce vivamus. Volutpat risus tortor duis enim lacinia per aliquam. Justo eleifend id neque purus; dapibus mus vestibulum et dis. Hac dui sollicitudin; luctus vel finibus rutrum nostra. Tristique dui tristique dapibus commodo turpis dolor placerat etiam. Vestibulum cursus urna facilisis interdum fringilla. Scelerisque egestas pellentesque ipsum nulla sem sapien orci torquent mauris.\n\nMalesuada neque taciti tempus maximus ex duis. Sociosqu fringilla porta mattis mattis in class. Ridiculus dui montes tortor porta sollicitudin. Ad dui odio ultrices elit suscipit. Torquent lacus penatibus eros vel nulla pretium inceptos accumsan cursus. Ex egestas netus ridiculus auctor ligula non aptent. Maximus risus vitae fringilla rhoncus nullam varius. Hendrerit inceptos pretium dis; neque mi consequat. Eleifend maximus quisque aptent urna sagittis tortor. Ornare lacus mi lobortis faucibus, faucibus quis elit faucibus.",
                  mood: "Lorem Ipsum",
                    ),
              );
  }
}

class EntryWritingPage extends StatelessWidget {
  const EntryWritingPage({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: [
            NavigationDashboard(),
            Expanded(
              child: Container(
                color: Color.fromARGB(255, 255, 178, 182),
                margin: EdgeInsets.all(20),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'How are you feeling today?',
                    //border: OutlineInputBorder(),
                  ),
                )
                ),
            ),
          ],
        ),
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

  EntryFormatting({super.key, required this.entry, required this.mood});

  @override
  Widget build(BuildContext context) {
    return 
        Container(
            // entry space around the page
            margin: const EdgeInsets.only(top: 30, bottom: 30, right: 30, left: 60),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              // background styling
              color: Color.fromARGB(255, 255, 194, 194),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            // height: 10,
            child: Align(
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  ListView(
                  children: [
                    Text(
                      date.format(today),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      "${time.format(today)} | Mood: $mood \n",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      entry,
                      style: TextStyle(fontSize: 15, letterSpacing: .6),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset( // find out how to make the image larger
                    'assets/mood1.png', 
                    color: const Color.fromRGBO(255, 255, 255, 0.5),
                    colorBlendMode: BlendMode.modulate
                      ),
                  ), 
                ],
              ),
            ),
          );
  }
}


// update it so it dynamically resizes, animation, gesture detection is only on the pot(?)
class NavigationButton extends StatelessWidget {
  final String page;

  const NavigationButton({super.key, required this.page});

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
  const NavigationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
                      MaterialPageRoute(builder: (context) => ViewEntryPage()),
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

class LevelBar extends StatefulWidget {
  const LevelBar({super.key,});

  @override
  State<LevelBar> createState() => _LevelBarState();
}

class _LevelBarState extends State<LevelBar> {
  // CURRENTLY HAS A LIMIT OF 200O EXP BEFORE IT OVERFLOWS
  // fix the math
  late Future<Album> _exp = getEXP();

  @override
  void initState() {
    super.initState();
    _exp = getEXP();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Level indicator
        FutureBuilder(
          future: _exp,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
              "LV ${snapshot.data!.exp / 100}:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
              }
            else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return CircularProgressIndicator();
            }
          ),

        // Level Bar
        Stack( 
          children: [
            FutureBuilder<Album>( // Exp bar
              future: _exp,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                          return Container(
                                    color: const Color.fromARGB(255, 255, 157, 170),
                                    child: SizedBox(
                                      width: snapshot.data!.exp / 10,
                                      height: 30,
                                    ),
                                  );
                                }
                else if(snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return CircularProgressIndicator();
                }
              ),
            Container( // Level bar border
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(192, 58, 58, 58),
                  width: 3,),
                borderRadius: BorderRadius.circular(3),
              ),
              child: SizedBox(
                width: 200,
                height: 25,
                ),
              ),
            ],
          ),
        
      ],
    );
  }
}
