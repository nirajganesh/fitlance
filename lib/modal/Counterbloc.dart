import 'dart:async';

class Counterbloc
{
  final stateStreamcontroller=StreamController<String>();
  StreamSink<String> get  member_date_sink =>stateStreamcontroller.sink;
  Stream<String> get  member_date_stream=>stateStreamcontroller.stream;
  dispose() {
    stateStreamcontroller.close();
  }
}