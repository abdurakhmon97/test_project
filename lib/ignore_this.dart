import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class IgnoreThis extends StatefulWidget {
  const IgnoreThis({Key? key}) : super(key: key);

  @override
  _IgnoreThisState createState() => _IgnoreThisState();
}

class _IgnoreThisState extends State<IgnoreThis> {
  File? _displayImage;

  final String _url =
      'https://www.kindacode.com/wp-content/uploads/2022/02/orange.jpeg';

  Future<void> _download() async {
    final response = await http.get(Uri.parse(_url));

    // Get the image name
    final imageName = path.basename(_url);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$imageName"),
        duration: Duration(seconds: 4),
      ),
    );
    // Get the document directory path
    final appDir = await pathProvider.getTemporaryDirectory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${appDir.path}"),
        duration: Duration(seconds: 4),
      ),
    );

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);

    // Downloading
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);

    setState(() {
      _displayImage = imageFile;
    });
  }

  void checkImage() async {
    try {
      final imageName = path.basename(_url);
      final appDir = await pathProvider.getTemporaryDirectory();
      final localPath = path.join(appDir.path, imageName);
      final imageFile = File(localPath);
      bool exists = await imageFile.exists();
      if (exists) {
        setState(() {
          _displayImage = imageFile;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      checkImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindacode.com'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: _download, child: const Text('Download Image')),
              const SizedBox(height: 25),
              CachedNetworkImage(
                imageUrl: _url,
                fadeInDuration: const Duration(seconds: 2),
                fadeOutDuration: const Duration(seconds: 2),
                placeholderFadeInDuration: const Duration(seconds: 2),
                placeholder: (ctx, str) {
                  return _displayImage != null ? Image.file(_displayImage!) : const FlutterLogo();
                },
                errorWidget: (_, __, ___) {
                  return const FlutterLogo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
