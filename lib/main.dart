import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

final MethodChannel platform = const MethodChannel('vision_channel');

main() {
  runApp(new MaterialApp(
    home: new HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File currentPhoto;
  List<String> currentLabels = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('ML Era'),
        actions: <Widget>[
          new FlatButton(
            child: const Text(
              'Album',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              File file =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              List<String> labels = await getLabels(file?.path);
              setState(() {
                currentLabels = labels;
                currentPhoto = file;
              });
            },
          ),
        ],
      ),
      body: new Container(
          child: new Column(
        children: <Widget>[
          new Flexible(
              flex: 1,
              child: new Container(
                child:
                    currentPhoto != null ? new Image.file(currentPhoto) : null,
              )),
          new Flexible(
            flex: 2,
            child: new Container(
              child: new ListView(
                children: currentLabels.map((String label) {
                  return new ListTile(
                    title: new Text(label),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      )),
      floatingActionButton: new FloatingActionButton(
        onPressed: () async {
          File file = await ImagePicker.pickImage(source: ImageSource.camera);
          List<String> labels = await getLabels(file?.path);
          setState(() {
            currentLabels = labels;
            currentPhoto = file;
          });
        },
        child: new Icon(Icons.camera),
      ),
    );
  }
}

Future<List<String>> getLabels(String filePath) async {
  List<String> labels = [];
  try {
    List<dynamic> firLabels = await platform.invokeMethod(
      'get_labels',
      {'image_path': filePath},
    );
    print(firLabels);
    firLabels.forEach((label) {
      labels.add(label);
    });
    return labels;
  } on PlatformException catch (e) {
    print(e);
    return labels;
  }
}
