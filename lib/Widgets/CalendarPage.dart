import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scalender/Widgets/Eventcard.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Event.dart';
import 'package:scalender/Data/DatabaseHelper.dart';
// Import the custom event card widget

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> eventTasks = await db.query('EventTask');

    Map<DateTime, List<Event>> events = {};
    for (var eventTask in eventTasks) {
      DateTime eventDate =
          DateFormat('yMMMd').add_jm().parse(eventTask['stdatetime']);
      DateTime eventDateOnly =
          DateTime(eventDate.year, eventDate.month, eventDate.day);
      Event event = Event(
        title: eventTask['title'],
        date: eventDate,
        description: eventTask['descr'],
        status: eventTask['status'],
        id: eventTask['eid'],
      );

      if (events[eventDateOnly] == null) {
        events[eventDateOnly] = [];
      }
      events[eventDateOnly]!.add(event);
    }

    setState(() {
      _events = events;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 8.0),
          ..._getEventsForDay(_selectedDay ?? _focusedDay).map(
            (event) => EventCard(event: event),
          ),
        ],
      ),
    );
  }
}
