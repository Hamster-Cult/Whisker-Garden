import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart';

import './helper.dart';

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
class TitlePage extends StatefulWidget {
  const TitlePage({super.key});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  // List<dynamic> _loggedIn = [];
  Widget nextPage = HomePage();

  void checkUser() async {
    Response response = await getData2("/user");
    setState(() {
      if (response.statusCode == 404) {
      nextPage = makeUserPage();
    }
    });
  }
  
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => nextPage));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                children: [
                      Expanded(child: Image.asset('assets/logo.png')),
                      Text('tap to start'),
                    ] ,
                  ),
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
  String username = "";

  void getUsername() async {
    List<dynamic> userDetails = await getData("/user");
    setState(() {
      username = userDetails[0]['username'];
    });
  }
  // make the messages more dynamic based on how long your streak has been?
  String message = "Your plant is doing great!";

  @override
  void initState() {
    super.initState();
    getUsername();
    data = getData('/garden/current-details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: Column(
              children: [
                NavigationDashboard(),
                Stack(
                  children: [
                    Text("Welcome $username!"),
                    FutureBuilder<List<dynamic>>(
                      future: getData('/garden/current-details'),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // fetch the 0 aswell
                          int plantID = snapshot.data![0]['plant_id'];
                          int plantAge = snapshot.data![0]['maturity'];
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
                    future: getData('/garden/current-details'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data![0]['plant_exp'] == 0) {
                          return Column(
                          children: [
                            Text("Water your new sapling!"),
                            CustomButton(destination: MoodLoggingPage(),
                            text: 'water plant')
                            ]
                          );
                        }
                        String lastWatered = snapshot.data![0]['last_watered'];
                        DateTime formatted = DateTime.parse(lastWatered);
                        lastWatered = DateFormat('dd MMMM yyy').format(formatted);
                        String today = DateFormat('dd MMMM yyy').format(DateTime.now());

                        if (today != lastWatered) {
                          message = "Water your plant today?";
                          return Column(
                          children: [
                          Text(message), CustomButton(destination: MoodLoggingPage(), text: 'yes!')
                          // allow the user to write more than one entry per day?
                          ],
                        );
                        } else { //delete this lol just for testing rn
                          return Column(
                          children: [
                          Text(message + " (this is just to test the exp)"), CustomButton(destination: MoodLoggingPage(), text: 'yes!')
                          // allow the user to write more than one entry per day?
                          ],
                        );
                        }
                        return Text(message);
                      } else if(snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return Text('fetching failed, refresh?');
                      }
                    ),
                    GestureDetector(
                  onTap: () {
                    getData("/delete");
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TitlePage()));
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
                                'delete user',
                                style: TextStyle(color: const Color.fromARGB(255, 197, 197, 197), fontSize: 20),
                                ),
                            ),
                          ],
                        ),
                      ),
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
  List<Widget> entries = [];
  int _currentPage = 1;
  //make a page that prompts the user to make an entry if there are none

  void fillEntryPages() async {
    final List<dynamic> data = await getData('/entries/$_currentPage');
    entries = []; // clears the list for each refresh

    for (var item in data) { // each page has a max of 4 entries shown at a time
      setState(() {
        entries.add(MiniEntryView(entry: item['entry'], mood: item['rating'].toString()));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fillEntryPages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NavigationDashboard(),
          LevelBar(),
          Column(children: entries), // change to ListView? perhaps?
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                      _currentPage --;
                      fillEntryPages();}
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(right: 300, left: 30),
                  width: 80,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 194, 194),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text(
                      '<',
                      style: TextStyle(
                        color: Color.fromARGB(255, 194, 96, 133),
                        fontSize: 30)),
                  ),
                  )
                ),
                GestureDetector(
                onTap: () {
                  setState(() {
                    // error handling if it goes to far ahead or back
                    _currentPage ++;
                      fillEntryPages();}
                  );
                },
                child: Container(
                  width: 80,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 194, 194),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text(
                      '>',
                      style: TextStyle(
                        color: Color.fromARGB(255, 194, 96, 133),
                        fontSize: 30)),
                  ),
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
          calendarView(),
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
                      margin: EdgeInsets.only(top: 20, bottom: 20, right: 230, left: 60),
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
                      margin: EdgeInsets.only(top: 100, bottom: 20, right: 200, left: 80),
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
            CustomButton(destination: SubmissionPage(mood: mood, entryWritten: false, entry: ''), text: 'no')
            ],
          ),

        ],
      ),
    );
  }
}


class SubmissionPage extends StatefulWidget {
  final bool entryWritten;
  final int mood;
  final String? entry;
  const SubmissionPage ({
    super.key,
    required this.entryWritten,
    required this.mood,
    this.entry });

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  List<dynamic> userData = [];
  List<dynamic> plantData = [];
  List<int> levelDetails = [];

  void getUserData() async{
    final List<dynamic> userFetch = await getData("/user");
    final List<dynamic> plantFetch = await getData("/garden/current-details");
    setState(() {
    userData = userFetch;
    plantData = plantFetch;
    int exp = 5; // always gain 5xp from watering
    levelDetails = calculateLevel(
                  exp,
                  userData[0]['exp'],
                  userData[0]['level']);
    plantData[0]['plant_exp'] += exp;
    plantData[0]['maturity'] = getGrowthStage(plantData[0]['plant_exp']);
    });
  }

  List<Widget> submissionCheck = [];
  void showEditEntry() {
    if (widget.entryWritten) {
      submissionCheck.add(
        Column(children: [
          Text(widget.entry!),
          CustomBackButton(text: 'edit entry'),
        ],)
      );
    }
  }

  @override 
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset('assets/emotions/${widget.mood}.png'),
              CustomButton(
                destination: MoodLoggingPage(), //pop this to take it back to the previous state instead of starting a new
                text: 'edit mood'),
                ],
              ),
            Column(
              children: submissionCheck,
            ),

            GestureDetector( //submit bttn
              onTap: () { //error handling here pls
                Map entryData =
                  {
                  "entry": "${widget.entry}",
                  "entry_date": DateFormat('y-MM-d').format(DateTime.now()),
                  "entry_time": DateFormat('HH:MM').format(DateTime.now()),
                  "rating": widget.mood,
                  };

                Map updateEXP =
                  {
                  "user_id": 1,
                  "plant_id": userData[0]['plant_id'],
                  "username": userData[0]['username'],
                  "level": levelDetails[1],
                  "exp": levelDetails[0]
                  };
                
                Map updatePlant =
                  {
                  "garden_slot": 2,
                  "plant_id": userData[0]['plant_id'],
                  "name": userData[0]['name'],
                  "archived": false, //if they've achieved their goal then?
                  "maturity": plantData[0]['maturity'],
                  "plant_exp": plantData[0]['plant_exp'],
                  "last_watered": DateFormat('y-MM-d').format(DateTime.now())
                  };
                
                sendData('/entry', entryData);
                sendData('/water', updateEXP);
                sendData('/water/plant', updatePlant);

                Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ViewEntryPage(
                          mood: '${widget.mood}',
                          entry: widget.entry!,
                          fromSubmission: true,
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
  final bool fromSubmission;
  final today = DateTime.now();
  final DateFormat date = DateFormat('dd MMMM yyy');
  final DateFormat time = DateFormat('H:m');

  final String entry;
  final String mood;

  ViewEntryPage({super.key, 
  required this.entry, 
  required this.mood,
  required this.fromSubmission});

  String convertMood() {
    List moods = ['estatic', 'good', 'neutral', 'sad', 'gloomy'];
    String moodText = moods[int.parse(mood)-1];
    return moodText;
  }

  @override
  Widget build(BuildContext context) {
    final Widget backButton;
    if (fromSubmission) {
      backButton = CustomButton(
        destination: HomePage(),
        text: 'home');
    } else {backButton = CustomBackButton(text: 'back');}

    return
        Scaffold(
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                child: LevelBar()
              ),
              // add the plant that grew for the entry?
              Container( // turn this into a list view for long text
                  margin: const EdgeInsets.only(top: 30, bottom: 40, right: 20, left: 20),
                  padding: const EdgeInsets.only(bottom: 25, left:15, right:15, top:15),
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
                          style: TextStyle(
                            color: Color.fromARGB(255, 101, 29, 73),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "${time.format(today)} | Mood: ${convertMood()} \n",
                          style: TextStyle(
                            color: Color.fromARGB(255, 101, 29, 73),
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                        ),
                        Text(
                          entry,
                          style: TextStyle(
                            color: Color.fromARGB(255, 194, 96, 133),
                            fontSize: 15,
                            ),
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
              backButton,
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

  String trimEntry() {
    String miniEntry = entry;
    if (miniEntry.length > 20) {
      miniEntry = "${miniEntry.substring(0, 20)}...";
    }
    return miniEntry;
  }

  String convertMood() {
    List moods = ['estatic', 'good', 'neutral', 'sad', 'gloomy'];
    String moodText = moods[int.parse(mood)-1];
    return moodText;
  }
  
  @override
  Widget build(BuildContext context) {
    return
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => 
                      ViewEntryPage(entry: entry,
                      mood: mood,
                      fromSubmission: false,)
                      ));
          },
          child: Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30, right: 30, left: 60),
              padding: const EdgeInsets.all(10),
              height: 100,
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
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 29, 73),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,),
                        textAlign: TextAlign.left,
                        ),
                        Text(
                          "${time.format(today)} | Mood: ${convertMood()} \n",
                          style: TextStyle(
                            color: Color.fromARGB(255, 101, 29, 73),
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                        ),
                        Text(
                          trimEntry(),
                          style: TextStyle(
                            color: Color.fromARGB(255, 194, 96, 133),
                            fontSize: 13)),
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
                  child: NavigationButton(page: 'entries')
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
              "LV ${snapshot.data![0]['level']}: exp: ${snapshot.data![0]['exp']}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
              }
            else if (snapshot.hasError) {
              return Text("failed to fetch data: ${snapshot.error}");
            }
            return Text('something went wrong try refreshing');
            } 
          ),

        // exp bar
          Stack(
            children: [
            FutureBuilder<List<dynamic>>( // Exp bar
              future: _exp,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  double exp = snapshot.data![0]['exp']; // handle higher levels
                      return Container(
                                color: const Color.fromARGB(255, 255, 157, 170),
                                child: SizedBox(
                                  width: exp * (4/3), // multiplied by 4/3 to fill into 200px
                                  height: 30,
                                ),
                              );
                            }
                else if (snapshot.hasError) {
                  return Text('failed to get exp: ${snapshot.error}');
                }
                return Text('something went wrong try refreshing');
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

class calendarView extends StatefulWidget {
  calendarView ({super.key});

  @override
  State<calendarView> createState() => _calendarViewState();
}

  Color filledColor = Color.fromARGB(255, 188, 161, 193);

class _calendarViewState extends State<calendarView> {
  Widget dayFilled = Container(
      margin: EdgeInsets.only(right: 30, top: 5, bottom: 5),
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color:  filledColor,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
    );

  List<Widget> calendarRows = [];

  String today = DateFormat('dd MMMM yyy').format(DateTime.now());

  void fillCalendar() async {
    String _year = today.substring(6);
    String _month = today.substring(3, 6);

    calendarRows = []; // clears the list for each refresh
    calendarRows.add(
      Align(
        alignment: Alignment.topLeft,
        child: Text(
            "$_month, $_year",
            style: TextStyle(
              color: Color.fromARGB(255, 101, 29, 73),
              fontWeight: FontWeight.bold,
              fontSize: 15,),
          ),
      ),
    );
    String todayURL = DateFormat('y-MM-d').format(DateTime.now()).substring(0, 7);
    //final List<dynamic> data = await getData('/calendar/$todayURL-1'); // doesn't work rn

    for (var i = 0; i < 4; i++) {
        List<Widget> tempRow = [];
        for (var i = 0; i < 8; i++) {
          /*
          for (var item in data) {
            filledColor = Color.fromARGB(255, 166, 133, 217);
            setState(() {tempRow.add(dayFilled);});
          }*/
          setState(() {tempRow.add(dayFilled);});
          // needs to correspond with day,,,
        }
        calendarRows.add(
          Row(children: tempRow)
        );
    }
  }

  @override
  void initState() {
    super.initState();
    fillCalendar();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
          height: 210,
          width: 500,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 194, 194),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: calendarRows
          ),
        ),
        //Image.asset('may.png'), adding graph stats here
      ],
    );
  }
}

class makeUserPage extends StatefulWidget {

  @override
  State<makeUserPage> createState() => _makeUserPageState();
}

class _makeUserPageState extends State<makeUserPage> {
  final usernameController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
          children: [
            Text('username:'),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10),
                color: const Color.fromARGB(255, 240, 175, 177),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'name',
                  ),
                ),
              ),
            ),
            ],
          ),
          GestureDetector(
                  onTap: () {
                    getData('/setup/${usernameController.text}');
                    Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => HomePage()));
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
                                'begin!',
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

