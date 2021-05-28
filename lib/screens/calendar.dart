import 'dart:developer';

import 'package:calendar_application/models/event_list.dart';
import 'package:calendar_application/screens/event_editor.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'dart:async';

// ignore: must_be_immutable
class CalendarPage extends StatelessWidget {
  EventListModel _eventList;
  final CalendarController _controller = CalendarController();

  @override
  Widget build(BuildContext context) {
    _eventList = Provider.of<EventListModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: FutureBuilder(
          future: _getGoogleCalendarData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return SfCalendar(
              allowViewNavigation: true,
              onTap: calendarTapped,
              controller: _controller,
              backgroundColor: Theme.of(context).backgroundColor,
              cellBorderColor: Colors.white,
              view: CalendarView.month,
              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: TextStyle(color: Colors.white),
                dateTextStyle: TextStyle(color: Colors.white),
              ),
              headerStyle: CalendarHeaderStyle(
                  backgroundColor: Colors.black,
                  textStyle: TextStyle(color: Colors.white, fontSize: 18.0)),
              dataSource: MeetingDataSource(source: _eventList.getEventList()),
              monthViewSettings: MonthViewSettings(
                  monthCellStyle:
                      MonthCellStyle(textStyle: TextStyle(color: Colors.white)),
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment),
              scheduleViewSettings: ScheduleViewSettings(
                  weekHeaderSettings: WeekHeaderSettings(
                      weekTextStyle: TextStyle(color: Colors.white)),
                  dayHeaderSettings: DayHeaderSettings(
                      dateTextStyle: TextStyle(color: Colors.white),
                      dayTextStyle: TextStyle(color: Colors.white))),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final googleAPI.CalendarApi calendarAPI = await _getClient();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventEditor(
                  calendarAPI: calendarAPI,
                ),
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future _getGoogleCalendarData() async {
    final googleAPI.CalendarApi calendarAPI = await _getClient();
    final googleAPI.Events calEvents = await calendarAPI.events.list(
      "primary",
    );
    _eventList.setEventList(calEvents.items);
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (_controller.view == CalendarView.day &&
        calendarTapDetails.targetElement == CalendarElement.header) {
      _controller.view = CalendarView.month;
    }
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '489608160427-3n3js4fhtic63nrs2qlvaaknoke0unj5.apps.googleusercontent.com',
    scopes: <String>[googleAPI.CalendarApi.CalendarScope]);

Future<googleAPI.CalendarApi> _getClient() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleAPIClient httpClient =
      GoogleAPIClient(await googleUser.authHeaders);
  final googleAPI.CalendarApi calendarAPI = googleAPI.CalendarApi(httpClient);
  return calendarAPI;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource({List<googleAPI.Event> source}) {
    this.appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final googleAPI.Event event = appointments[index];
    return event.start.date ?? event.start.dateTime.toLocal();
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final googleAPI.Event event = appointments[index];
    return event.endTimeUnspecified != null && event.endTimeUnspecified
        ? (event.start.date ?? event.start.dateTime.toLocal())
        : (event.end.date != null
            ? event.end.date.add(Duration(days: -1))
            : event.end.dateTime.toLocal());
  }

  @override
  String getLocation(int index) {
    return appointments[index].location;
  }

  @override
  String getNotes(int index) {
    return appointments[index].description;
  }

  @override
  String getSubject(int index) {
    final googleAPI.Event event = appointments[index];
    String eventName = event.summary == null || event.summary.isEmpty
        ? 'No Title'
        : event.summary;
    log(eventName);
    return eventName;
  }
}

class GoogleAPIClient extends IOClient {
  Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}
