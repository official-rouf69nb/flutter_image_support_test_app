import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:image/image.dart' as image;
import 'package:flutter/services.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    var fileName = "RAW_FUJI_S5000.RAF";
    getUiImage("assets/$fileName").then((value){
    //   getImage2("assets/$fileName").then((value){
      //getImage3(value!).then((value){});
      print("sdf");
    }).catchError((e){
      print(e.toString());
    });
  }



  Future<Uint8List?> getUiImage(String imageAssetPath) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    ui.Codec codec = await ui.instantiateImageCodec(Uint8List.view(assetImageByteData.buffer));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    var image = frameInfo.image;
    final data = await image.toByteData(format: ImageByteFormat.rawRgba);
    final jpg = JpegEncoder().compress(data!.buffer.asUint8List(), image.width, image.height, 100);

    var dir = await getTemporaryDirectory();
    var path = "${dir.path}/$imageAssetPath.jpg";
    File(path).create(recursive: true);
    await File(path).writeAsBytes(jpg);
    return jpg;
  }

  Future<void> getImage2(String imageAssetPath)async{
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    var lData = Uint8List.view(assetImageByteData.buffer);
    var img = image.decodeImage(lData);


    var dir = await getTemporaryDirectory();
    var path = "${dir.path}/$imageAssetPath.jpg";
    File(path).create(recursive: true);
    await File(path).writeAsBytes(image.encodeJpg(img!));
  }


  Future<void> getImage3(Uint8List imgData)async{
    var img = image.decodeImage(imgData);


    var dir = await getTemporaryDirectory();
    var path = "${dir.path}/sample_1.jpg";
    File(path).create(recursive: true);
    await File(path).writeAsBytes(image.encodeJpg(img!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Image.asset("assets/calella3.dng"),
            // Image.asset("assets/calella3.dng"),
            // Image.asset("assets/4.jpg"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
