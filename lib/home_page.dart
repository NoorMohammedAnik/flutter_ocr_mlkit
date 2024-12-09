import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ocr_mlkit/recognition_view.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late XFile? pickImage;
  late String resultText;



  @override
  void initState() {
    pickImage = null;
    resultText = '';
    super.initState();
  }

  //pick image from camera or gallery
  Future<void> getImage(ImageSource imgSource) async {
    try {
      pickImage = (await ImagePicker().pickImage(source: imgSource))!;
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Flutter OCR App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              tooltip: "Copy Text",
              onPressed: () {
                Clipboard.setData(ClipboardData(text: resultText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Text copied to clipboard!')),
                );
              },
              icon: Icon(
                Icons.copy,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          pickImage == null
              ? 'No image selected yet.\nYou can select an image by clicking the + button'
              : 'Result scan:\n$resultText',
          style: const TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            builder: (BuildContext context) {
              final items = ['Camera', 'Gallery'];

              return ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Icon(
                      index == 0
                          ? Icons.camera_alt_outlined
                          : Icons.photo_library_outlined,
                    ),
                    title: Text(items[index]),
                    onTap: () async {
                      await getImage(
                        index == 0 ? ImageSource.camera : ImageSource.gallery,
                      ).then(
                        (value) async {
                          resultText = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecognitionPage(xFile: pickImage!),
                            ),
                          );
                        },
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                  );
                },
              );
            },
          );
        },
        backgroundColor: Colors.blue,
        label: const Text(
          'Add image',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.add_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}
