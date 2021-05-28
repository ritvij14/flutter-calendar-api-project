// import 'package:calendar_application/models/event.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart';

class EventListModel with ChangeNotifier {
  static List<Event> _eventList = [];

  List<Event> getEventList() {
    return _eventList;
  }

  void setEventList(List<Event> eventList) {
    if(_eventList.isEmpty) {
      for (Event e in eventList) {
        _eventList.add(e);
      }
    }
  }

  void addEvent(Event meeting) {
    _eventList.add(meeting);
    notifyListeners();
  }

  void removeEvent(Event meeting) {
    _eventList.remove(meeting);
    notifyListeners();
  }

  /*void updateEvent(EventModel meeting, int id) {
    _eventList.insert(id, meeting);
    notifyListeners();
  }*/
}
