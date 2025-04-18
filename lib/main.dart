import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time
import 'client.dart'; // Handels fetching data

void main() {
  runApp(const MainApp());
}

// main app widget
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
// this is the first page the user sees when they open the app
class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
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

// default page after the title page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final today = DateTime.now();
  late Future<List<dynamic>> data;
  // make the messages more dynamic based on how long your streak has been?
  String message = "Your plant is doing great!";


  @override
  void initState() {
    super.initState();
    data = getData('/garden/last');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: Column(
              children: [
                NavigationDashboard(),
                Stack(
                  children: [
                    FutureBuilder<List<dynamic>>(
                      future: getData('/user/plant'),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // fetch the 0 aswell
                          int plantID = snapshot.data![0]['plant_id'];
                          //int plantAge = snapshot.data!['plantMaturity'];
                          int plantAge = 2;
                          String plantPath = "/$plantID/$plantAge.png";

                          return Image.asset("assets/plants$plantPath");

                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return Text('failed to fetch plant');
                      },
                    ),
                    //add cat animation
                  ],
                ),
                Align(alignment: Alignment.center, child: LevelBar()),
                FutureBuilder<List<dynamic>>( // fetching the date to notify the user if they need to water the plant or not
                    future: getData('/garden/last'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        String lastWatered = snapshot.data![0]['last_watered'];
                        DateTime formatted = DateTime.parse(lastWatered);
                        lastWatered = DateFormat('dd MMMM yyy').format(formatted);
                        String today = DateFormat('dd MMMM yyy').format(DateTime.now());
                        print(DateFormat('HH:MM').format(DateTime.now()));

                        if (today != lastWatered) {
                          message = "Water your plant today?";
                          return Column(
                          children: [
                          Text(message), CustomButton(destination: MoodLoggingPage(), text: 'yes!')
                          // allow the user to write more than one entry per day?
                          ],
                        );
                        }
                        return Text(message);
                      }

                      else if(snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return Text(message);
                      }
                    ),
                  ],
                ),
              );
  }
}

// to do list page
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
          // create new task text
          CustomButton(destination: TaskCreationPage(), text: "Create new task"),
        ],
      ),
    );
  }
}

// task creation page
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
// this is the calendar page where the user can see their entries
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  int _totalEntries = 9;
  List<List<MiniEntryView>> entries = [];

  // takes the total number of entries in the db and makes a new
  // 'page' in the form of a list to store the widgets
  void makeEntryPages() {
    if (_totalEntries == 0) {
      //make a page that prompts the user to make an entry
    }
    else {
      for (var i = 0; i < _totalEntries; i+=4) {
        entries.add([]);
      }
    }
  }

  void fillEntryPages() async {

    for (var i = 0; i < 3; i++) { // each page has a max of 4 entries shown at a time
      entries[_currentPage].add(
        MiniEntryView(entry: entry, mood: mood)
      );
    }
  }

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> displayEntries = entries[_currentPage];

    return Scaffold(
      body: Column(
        children: [
          NavigationDashboard(),
          LevelBar(),
          Column(children: displayEntries),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_currentPage > 0) {_currentPage --;}
                  });
                },
                child: Container(
                  width: 100,
                  height: 70,
                  color: Colors.blueGrey,
                  child: Text('<'),
                  )
                ),
                GestureDetector(
                onTap: () {
                  setState(() {
                    if (_currentPage < entries.length) {_currentPage ++;} // fetch the total number of entries and divide by 4
                  });
                },
                child: Container(
                  width: 100,
                  height: 70,
                  color: Colors.blueGrey,
                  child: Text('>'),
                  )
                ),
            ],
          ),
        ],
      ),
    );
  }
}


// statistics page
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

// shelf page
class GardenShelfPage extends StatefulWidget {
  const GardenShelfPage({super.key});

  @override
  State<GardenShelfPage> createState() => _GardenShelfPageState();
}

// has the information for the plants on the shelf
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

// mood logging page
// this is the page where the user can log their mood
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
                      child: Image.asset('assets/emotions/2.png')
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
                      child: Image.asset('assets/emotions/1.png'),
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
            CustomButton(destination: HomePage(), text: 'cancel'),
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
          Row(
            children: [
              Image.asset('assets/emotions/$mood.png'),
              CustomBackButton(text: 'edit mood'),
            ],
          ),
          Text("Would you like to add an entry?"),
          Row(
            children: [
            CustomButton(destination: EntryWritingPage(mood: mood), text: 'yes'),
            CustomButton(destination: SubmissionPage(mood: mood, entryWritten: false,), text: 'no')
            ],
          ),

        ],
      ),
    );
  }
}


// (if this has a submission button then keep it seperate if not just use viewentrypage)
// okay I'm barely functional rn I have no idea what I'm writing so the code is probably trash but uhm
// change the destination page if you don't write an entry and just log your mood
// this probably has implications for the db but I can't think aaaaa
class SubmissionPage extends StatelessWidget {
  final bool entryWritten;
  final int mood;
  final String? entry;
  const SubmissionPage ({
    super.key,
    required this.entryWritten,
    required this.mood,
    this.entry });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset('assets/emotions/$mood.png'),
              CustomButton(
                destination: MoodLoggingPage(), //pop this to take it back to the previous state instead of starting a new
                text: 'edit mood'),
            ],
          ),

          Visibility(
            visible: entryWritten,
            child: Column(
              children: [
                Text(entry!),
                CustomBackButton(text: 'edit entry'),
              ],
            ),
            ),
            //CustomButton(destination: ViewEntryPage(), text: 'sumbnit!'),
            GestureDetector(
              onTap: () {
                Map data =
                  {
                  "entry": "$entry",
                  "entry_date": "${DateFormat('y-MM-d').format(DateTime.now())}",
                  "entry_time": "${DateFormat('HH:MM').format(DateTime.now())}",
                  "rating": mood,
                  };

                sendData('/entry', data);
                Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ViewEntryPage(
                          mood: '$mood',
                          entry: entry!
                        )));
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
                            'submit',
                            style: TextStyle(color: const Color.fromARGB(255, 197, 197, 197), fontSize: 20),
                            ),
                        ),
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

// Make a function that updates all the user values

// test unicode and special characters make sure the db can handle it as well
class EntryWritingPage extends StatefulWidget {
  final int mood;
  const EntryWritingPage({super.key, required this.mood});

  @override
  State<EntryWritingPage> createState() => _EntryWritingPageState();
}

class _EntryWritingPageState extends State<EntryWritingPage> {
  final entryController = TextEditingController();


  @override
  void dispose() {
    entryController.dispose();
    super.dispose();
  }

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
                  controller: entryController,
                  decoration: InputDecoration(
                    labelText: 'How are you feeling today?',
                    //border: OutlineInputBorder(),
                  ),
                )
                ),
            ),
            Row(
              children: [
                CustomBackButton(text: "cancel"),
                GestureDetector(
                  onTap: () { // find out how to change the image shown on tap
                    Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SubmissionPage(
                              mood: widget.mood,
                              entryWritten: true,
                              entry: entryController.text
                              )
                            )
                          );
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
                                'finish',
                                style: TextStyle(color: const Color.fromARGB(255, 197, 197, 197), fontSize: 20),
                                ),
                            ),
                          ],
                        ),
                      ),
                    )
              ],
            ),
          ],
        ),
      );
  }
}


// Defining custom widgets


// - Figure out how to format with paragraph breaks
class ViewEntryPage extends StatelessWidget {
  final today = DateTime.now();
  final DateFormat date = DateFormat('dd MMMM yyy');
  final DateFormat time = DateFormat('H:m');

  final String entry;
  final String mood;

  ViewEntryPage({super.key, required this.entry, required this.mood});

  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
          body: Column(
            children: [
              LevelBar(),
              // add the plant that grew for the entry?
              Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 30, right: 30, left: 60),
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    // background styling
                    color: Color.fromARGB(255, 255, 194, 194),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Stack(
                    children: [
                      Column(
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
                        'assets/emotions/$mood.png',
                        color: const Color.fromRGBO(255, 255, 255, 0.5),
                        colorBlendMode: BlendMode.modulate
                          ),
                      ),
                    ],
                  ),
                ),
                CustomBackButton(text: 'back')
            ],
          ),
        );
  }
}

// mini view
// fix the alignment
class MiniEntryView extends StatelessWidget {
  final today = DateTime.now();
  final DateFormat date = DateFormat('dd MMMM yyy');
  final DateFormat time = DateFormat('H:m');

  final String entry;
  final String mood;

  MiniEntryView({super.key, required this.entry, required this.mood});

  @override
  Widget build(BuildContext context) {
    return
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ViewEntryPage(entry: entry, mood: mood)));
          },
          child: Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30, right: 30, left: 60),
              padding: const EdgeInsets.all(20),
              height: 200,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 194, 194),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Stack(
                  children: [
                    Column(
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
                        Text(entry),
                       ],
                      ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset( // find out how to make the image larger
                      'assets/$mood.png',
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
                      MaterialPageRoute(builder: (context) => HomePage()),
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

class LevelBar extends StatefulWidget {
  const LevelBar({super.key,});

  @override
  State<LevelBar> createState() => _LevelBarState();
}

class _LevelBarState extends State<LevelBar> {
  // CURRENTLY HAS A LIMIT OF 200O EXP BEFORE IT OVERFLOWS
  // fix the math
  late Future<List<dynamic>> _exp = getData('/exp');

  @override
  void initState() {
    super.initState();
    _exp = getData('/exp');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Level indicator
        FutureBuilder<List<dynamic>>(
          future: _exp,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
              "LV ${snapshot.data![0]['level']}:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
              }
            else if (snapshot.hasError) {
              return Text('WOMP WOMP');
            }
            return Text('fetching....');
            }
          ),

        // Level Bar
          Stack(
            children: [
            FutureBuilder<List<dynamic>>( // Exp bar
              future: _exp,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                      return Container(
                                color: const Color.fromARGB(255, 255, 157, 170),
                                child: SizedBox(
                                  width: snapshot.data![0]['exp'] / 10,
                                  height: 30,
                                ),
                              );
                            }
                else if (snapshot.hasError) {
                  return Text('WOMP WOMP');
                }
                return Text('fetching....');
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