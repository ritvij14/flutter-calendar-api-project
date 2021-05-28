import 'dart:developer';

import 'package:calendar_application/models/event_list.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:provider/provider.dart';

class EventEditor extends StatelessWidget {
  final googleAPI.Event event = new googleAPI.Event();
  final googleAPI.CalendarApi calendarAPI;

  EventEditor({Key key, @required this.calendarAPI}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EventListModel _eventList = Provider.of<EventListModel>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Event editor'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  labelText: 'Enter title',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white.withOpacity(0.12),
                  // hintText: "USERNAME",
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Colors.white,
                          style: BorderStyle.solid,
                          width: 2.0)),
                ),
                onChanged: (value) => {event.summary = value},
              ),
              SizedBox(
                height: 40.0,
              ),
              DateTimePicker(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'From',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
                type: DateTimePickerType.dateTime,
                dateMask: 'd MMM, yyyy - hh:mm',
                initialValue: DateTime.now().toString(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                cursorColor: Colors.white,
                onChanged: (val) {
                  googleAPI.EventDateTime start = new googleAPI.EventDateTime();
                  start.dateTime = DateTime.parse(val);
                  start.timeZone = "GMT+05:30";
                  event.start = start;
                },
                validator: (val) {
                  print(val);
                  return null;
                },
                onSaved: (val) {
                  googleAPI.EventDateTime start = new googleAPI.EventDateTime();
                  start.dateTime = DateTime.parse(val);
                  start.timeZone = "GMT+05:30";
                  event.start = start;
                },
              ),
              SizedBox(
                height: 40.0,
              ),
              DateTimePicker(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'To',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
                type: DateTimePickerType.dateTime,
                dateMask: 'd MMM, yyyy - hh:mm',
                initialValue: DateTime.now().toString(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                cursorColor: Colors.white,
                onChanged: (val) {
                  googleAPI.EventDateTime end = new googleAPI.EventDateTime();
                  end.timeZone = "GMT+05:30";
                  end.dateTime = DateTime.parse(val);
                  event.end = end;
                  log(val);
                },
                validator: (val) {
                  print(val);
                  return null;
                },
                onSaved: (val) {
                  googleAPI.EventDateTime end = new googleAPI.EventDateTime();
                  end.timeZone = "GMT+05:30";
                  end.dateTime = DateTime.parse(val);
                  event.end = end;
                },
              ),
              SizedBox(
                height: 40.0,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await calendarAPI.events.insert(event, "primary").then(
                        (value) => {
                              if (value.status == 'confirmed')
                                log('event added')
                            });
                    _eventList.addEvent(event);
                    Navigator.pop(context);
                  },
                  child: Text('Save'))
            ],
          ),
        ),
      ),
    );
  }
}
