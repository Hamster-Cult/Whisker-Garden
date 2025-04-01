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
          CustomButton(destination: MoodLoggingPage(), text: 'yes!')
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
          Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          CustomButton(destination: TaskCreationPage(), text: "Create new task"),
        ],
      ),
    );
  }
}

class TaskCreationPage extends StatelessWidget {
  const TaskCreationPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Task creation page")
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

class GardenShelfPage extends StatefulWidget {
  const GardenShelfPage({super.key});

  @override
  State<GardenShelfPage> createState() => _GardenShelfPageState();
}

class _GardenShelfPageState extends State<GardenShelfPage> {
  // find out how to dynamically resize images

  // currently hardcoded plants, fetch the data
  List shelves = [
    GardenShelf(plants: [
      ShelfPlant(image: 'assets/plant-min2.png'),
      ShelfPlant(image: 'assets/plant-min2.png'),
      ShelfPlant(image: 'assets/plant-min2.png'),
      ]),
    GardenShelf(plants: [
      ShelfPlant(image: 'assets/plant-min.png'),
      ShelfPlant(image: 'assets/plant-min2.png'),
      ShelfPlant(image: 'assets/plant-min.png'),
      ShelfPlant(image: 'assets/plant-min.png'),
    ]),
  ];
  int _currentShelf = 0;

  void _onSwipeLeft() {setState(() {
      if (_currentShelf < shelves.length) {
        _currentShelf ++;
        }
    })
  ;}
  void _onSwipeRight() {setState(() {
    if (_currentShelf != 0) {
          _currentShelf --;
        } 
      })
    ;}

  @override
  Widget build(BuildContext context) {
    Widget displayShelf = shelves[_currentShelf];

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            NavigationDashboard(),
            LevelBar(),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) { // update which elemnts are shown
                    _onSwipeRight();
                  } else if (details.primaryVelocity! < 0) {
                    _onSwipeLeft();
                  }
                },
                child: displayShelf,
            ),
          ],
        ),
      ),
    );
  }
}

// functional and transitional pages

class MoodLoggingPage extends StatelessWidget {
  const MoodLoggingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              'Okay!\nHow was your day?',
              style: TextStyle(fontSize: 20)),
            // find out how to animate these
            // find out how to dynamically change the ui
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => WriteEntryPromptPage(mood: 3,)),
            );},
              child: Container(
                color: Color.fromARGB(255, 255, 178, 182),
                width: 70,
                height: 70,
                margin: EdgeInsets.all(20),
              ),
            ),
            Row(
              children: [
                GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => WriteEntryPromptPage(mood: 2,)),
                  );},
                    child: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20, right: 320, left: 60),
                      child: Image.asset('assets/emotions/good.png')
                    ),
                  ),
                GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => WriteEntryPromptPage(mood: 4,)),
                  );},
                    child: Container(
                      color: Color.fromARGB(255, 245, 191, 184),
                      width: 70,
                      height: 70,
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => WriteEntryPromptPage(mood: 1,)),
                  );},
                    child: Container(
                      margin: EdgeInsets.only(top: 100, bottom: 20, right: 300, left: 80),
                      child: Image.asset('assets/emotions/HAPPII.png'),
                    ),
                  ),
                GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => WriteEntryPromptPage(mood: 5,)),
                  );},
                    child: Container(
                      color: Color.fromARGB(255, 253, 184, 144),
                      width: 70,
                      height: 70,
                      margin: EdgeInsets.only(right: 10, top: 100),
                    ),
                  ),
              ],
            ),
            // fetch plant image
            CustomButton(destination: LandingPage(), text: 'cancel'),
          ],
        ),
      ),
    );
  }
}

// in-between page mood logging - entry writing (confirmation lol)
class WriteEntryPromptPage extends StatelessWidget {
  final int mood;// translate mood to text value
  const WriteEntryPromptPage ({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("You've selected $mood"),
          CustomBackButton(text: 'edit mood'),
          Text("Would you like to add an entry?"),
          CustomButton(destination: EntryWritingPage(), text: 'yes'),
          CustomButton(destination: SubmissionPage(entryWritten: false,), text: 'no')
        ],
      ),
    );
  }
}

// viewing the final daily selection 
// (if this has a submission button then keep it seperate if not just use viewentrypage)

// this page is entierly built upon what was done before so uhhhh,,,,,
class SubmissionPage extends StatelessWidget {
  final bool entryWritten;
  const SubmissionPage ({super.key, required this.entryWritten});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Here's all the stuff you've picked, submit?"),
          CustomButton(destination: MoodLoggingPage(), text: 'edit mood'),
          Visibility(
            visible: entryWritten,
            child: CustomBackButton(text: 'edit entry'),
            ),
            CustomButton(destination: ViewEntryPage(), text: 'sumbnit!'),
        ],
      ),
    );
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
            CustomBackButton(text: "cancel"),
            CustomButton(destination: SubmissionPage(entryWritten: true,), text: "finish"),
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


class CustomButton extends StatelessWidget {
  final Widget destination;
  final String text;
  const CustomButton({super.key, required this.destination, required this.text});

  @override
  Widget build(BuildContext context) {
    // find out how to disable continue until you pick an emotion
    return GestureDetector(
              onTap: () { // find out how to change the image shown on tap
                Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => destination));
                  },
                  child: SizedBox(
                    width: 200,
                    height: 80,
                    child: Stack(
                      children: [
                        Image.asset('assets/button_1.png'), // make the image smaller
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            text,
                            style: TextStyle(color: const Color.fromARGB(255, 197, 197, 197), fontSize: 20),
                            ),
                        ),
                      ],
                    ),
                  ),
                );
  }
}

class CustomBackButton extends StatelessWidget {
  final String text;
  const CustomBackButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // find out how to disable continue until you pick an emotion
    return GestureDetector(
      // find out how to change the image shown on tap
              onTap: () {Navigator.of(context).pop();},
                  child: SizedBox(
                    width: 200,
                    height: 80,
                    child: Stack(
                      children: [
                        Image.asset('assets/button_1.png'), // make the image smaller
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            text,
                            style: TextStyle(color: const Color.fromARGB(255, 197, 197, 197), fontSize: 20),
                            ),
                        ),
                      ],
                    ),
                  ),
                );
  }
}

class ShelfPlant extends StatelessWidget {
  final String image;
  const ShelfPlant ({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 40, right: 40, bottom: 80, top: 80),
      child: Image.asset(image),
    );
  }
}

class GardenShelf extends StatelessWidget {
  // limit it to 4 plants per row
  List<ShelfPlant> plants = []; // make this work lmao
  GardenShelf ({super.key, required this.plants});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset('assets/shelf.png'),
        Column(
          // iterate through plants and make rows based on that
          children: [
            Row(
            children: plants,
            ),
          ],
        ),
      ],
    );
  }
}

/*
class TaskBox extends StatelessWidget {
  const TaskBox ({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Here is an example of a task!'),
        Checkbox(value: value, onChanged: onChanged). // aaaa eepy figure this out later just turn the text strikethorugh or smth
      ],
    );
  }
}
*/