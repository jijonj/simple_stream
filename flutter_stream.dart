import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Stream',
      home: NumberStreamPage(),
    );
  }
}

class NumberStreamPage extends StatefulWidget {
  @override
  _NumberStreamPageState createState() => _NumberStreamPageState();
}

class _NumberStreamPageState extends State<NumberStreamPage> {
  late StreamController<String> _streamController;
  late Stream<String> _numberStream;
  final String apiUrl = 'http://10.0.2.2:8000/numbers';

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<String>();
    _numberStream = _streamController.stream;
    _startNumberStream();
  }

  void _startNumberStream() async {
    var client = http.Client();
    var request = http.Request('GET', Uri.parse(apiUrl));
    var streamedResponse = await client.send(request);

    streamedResponse.stream.transform(utf8.decoder).listen((event) {
      if (event.startsWith('data:')) {
        var number = int.parse(event.split(':')[1].trim());
        _streamController.add(event);
      }
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Stream'),
      ),
      body: StreamBuilder<String>(
        stream: _numberStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return Center(child: Text('${snapshot.data}'));
            } else {
              return Center(child: Text('Waiting for numbers...'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
