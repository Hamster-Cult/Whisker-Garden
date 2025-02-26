import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:icalendar_parser/icalendar_parser.dart';

class CalendarTest {
  // parse the contents to json
  Future<void> parseIcsAsJson() async {
    final String data = await rootBundle.loadString('./example.ics');
    final ICalendar ical = ICalendar.fromString(data);
    print(ical.toJson());
  }
}
