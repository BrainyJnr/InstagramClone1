import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utilis/utilis.dart';

class PofileScreen extends StatefulWidget {
  const PofileScreen({super.key});

  @override
  State<PofileScreen> createState() => _PofileScreenState();
}

class _PofileScreenState extends State<PofileScreen> {
  Uint8List? _image;

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: Icon(Icons.local_activity_rounded))
          ],
        ),
        body: Center(
          child: Stack(
            children: [
              _image != null
                  ? CircleAvatar(
                      radius: 64,
                      backgroundImage: MemoryImage(_image!),
                      backgroundColor: Colors.red,
                    )
                  : const CircleAvatar(
                      radius: 64,
                      backgroundImage:
                          NetworkImage('https://i.stack.imgur.com/l60Hf.png'),
                      backgroundColor: Colors.red,
                    ),
              Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(Icons.add_a_photo),
                  ))
            ],
          ),
        ));
  }
}
