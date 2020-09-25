import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = "init";
  String _outputPath = "";
  String _outputFileSize = "";

  Future<void> updateOutputState() async {
    final outputFile = File(_outputPath);
    if (await outputFile.exists()) {
      _outputFileSize = (await outputFile.length()).toString();
    } else {
      _outputFileSize = "-1";
    }
  }

  Future<void> compressVideo(String path) async {
    _status = 'compressing';
    setState(() {});

    final info = await VideoCompress.compressVideo(
      path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );

    _status = 'compressed';
    _outputPath = info.path;
    await updateOutputState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Status:',
            ),
            Text(
              '$_status',
              style: Theme.of(context).textTheme.bodyText1,
              key: Key('status'),
            ),
            Text(
              'Output Path:',
            ),
            Text(
              '$_outputPath',
              style: Theme.of(context).textTheme.bodyText1,
              key: Key('output_path'),
            ),
            Text(
              'Output File Size:',
            ),
            Text(
              '$_outputFileSize',
              style: Theme.of(context).textTheme.bodyText1,
              key: Key('output_file_size'),
            ),
            RaisedButton(
              key: Key('use_sample_video'),
              onPressed: () async {
                final data = await rootBundle.load(
                  'assets/samples/sample.mp4',
                );
                final bytes = data.buffer.asUint8List();
                final dir = await getTemporaryDirectory();
                final file =
                    await File('${dir.path}/sample.mp4').writeAsBytes(bytes);

                await this.compressVideo(file.path);
              },
              child: const Text('Use sample video'),
            ),
            RaisedButton(
              key: Key('select_video'),
              onPressed: () async {
                File file =
                    await ImagePicker.pickVideo(source: ImageSource.gallery);
                await this.compressVideo(file.path);
              },
              child: const Text('Select video'),
            ),
            RaisedButton(
              key: Key('clear_cache'),
              onPressed: () async {
                await VideoCompress.deleteAllCache();

                _status = 'cache cleared';
                await this.updateOutputState();
                setState(() {});
              },
              child: const Text('Clear cache'),
            ),
          ],
        ),
      ),
    );
  }
}
