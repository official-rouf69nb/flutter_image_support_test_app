import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  Uint8List? _outputImage;
  String _fileName = "";
  String _successMsg = "";
  String _errorMsg1 = "";
  String _errorMsg2 = "";

  void _incrementCounter() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      if(mounted) {
        setState(() {
          _successMsg = "";
          _errorMsg1 = "";
          _errorMsg2 = "";
          _outputImage = null;
          _fileName = result.files.single.name;
        });
      }

      File file = File(result.files.single.path!);
      var img = file.readAsBytesSync();

      ///Try 1
      _outputImage = await getUiImage(img);
      if(_outputImage != null){
        _successMsg = "Converted with RawImage";
      }
      else{
        ///Try 2
        _outputImage ??= await getImage(file.readAsBytesSync());
        if(_outputImage != null){
          _successMsg = "Converted with Image Package";
        }
      }

      if(mounted) {
        setState(() {
          _fileName = result.files.single.name;
        });
      }
    }
  }



  Future<Uint8List?> getUiImage(Uint8List imgBytes) async {
    try{
      // final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
      ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      var image = frameInfo.image;
      final data = await image.toByteData(format: ImageByteFormat.rawRgba);
      final jpg = JpegEncoder().compress(data!.buffer.asUint8List(), image.width, image.height, 100);

      // var dir = await getTemporaryDirectory();
      // var path = "${dir.path}/$imageAssetPath.jpg";
      // File(path).create(recursive: true);
      // await File(path).writeAsBytes(jpg);
      return jpg;
    }
    catch(ex){
      _errorMsg1 = ex.toString();
      return null;
    }
  }

  Future<Uint8List?> getImage(Uint8List imgBytes)async{
    try{
      //final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
      //var lData = Uint8List.view(assetImageByteData.buffer);
      var img = image.decodeImage(imgBytes);
      if(img != null) {
        var i = image.encodeJpg(img);
        return Uint8List.fromList(i);
      }else{
        _errorMsg2 = "Unable to parse file!";
        return null;
      }
    }
    catch(ex){
      _errorMsg2 = ex.toString();
      return null;
    }
  }


  // Future<void> getImage3(Uint8List imgData)async{
  //   var img = image.decodeImage(imgData);
  //   var dir = await getTemporaryDirectory();
  //   var path = "${dir.path}/sample_1.jpg";
  //   File(path).create(recursive: true);
  //   await File(path).writeAsBytes(image.encodeJpg(img!));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black12,
              child: AspectRatio(
                aspectRatio: 1.5,
                child: _outputImage != null
                ? Image.memory(
                  _outputImage!,
                  fit: BoxFit.contain,
                ) : const Offstage(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(_fileName.isNotEmpty) Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text("File: $_fileName"),
                      ),

                      if(_errorMsg1.isNotEmpty) Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text("Raw Error: $_errorMsg1"),
                      ),
                      if(_errorMsg2.isNotEmpty)Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text("PKG Error: $_errorMsg2"),
                      ),
                      if(_successMsg.isNotEmpty) Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          "Status: $_successMsg",
                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
