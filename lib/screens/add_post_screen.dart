import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/providers/user_providers.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utilis/colors.dart';
import 'package:instagram_clone/utilis/utilis.dart';
import 'package:provider/provider.dart';
import '../models/users.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  late Users users; // Declare the users field as late

  @override
  void initState() {
    super.initState();
    users = Provider.of<UserProvider>(context, listen: false).getUser;
  }

  // Fetch user data by UID
  Future<Users> getUserByUid(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('Instagram').doc(uid).get();
      if (userSnapshot.exists) {
        return Users.fromSnapshot(userSnapshot);
      } else {
        throw 'User not found';
      }
    } catch (e) {
      throw 'Error fetching user: $e';
    }
  }

  void postImage(String username, String uid, String? profileImage) async {
    if (_file == null) {
      showSnackBar("No image selected", context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profileImage!,
      );

      if (res == "success") {
        showSnackBar("Posted", context);
        clearImage();
      } else {
        showSnackBar("An error occurred: $res", context);
      }
    } catch (e) {
      showSnackBar("An error occurred: ${e.toString()}", context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Create a Post"),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Take a photo"),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Choose from gallery"),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Users user = Provider.of<UserProvider>(context).getUser;

    return FutureBuilder<Users>(
      future: getUserByUid(user.uid), // Fetch user by UID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return Center(child: Text("User not found"));
        } else {
          // Once data is available, access user data
          Users users = snapshot.data!;

          return _file == null
              ? Center(
            child: IconButton(
                onPressed: () => _selectImage(context),
                icon: Icon(Icons.upload)),
          )
              : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: clearImage,
                icon: Icon(Icons.arrow_back),
              ),
              title: const Text("Post to"),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () => postImage(
                    user.username,
                    user.uid,
                    user.photoUrl,
                  ),
                  child: Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Displaying user profile image in CircleAvatar
                    CircleAvatar(
                      backgroundImage: NetworkImage(users.photoUrl),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: "Write a caption...",
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: MemoryImage(_file!),
                                fit: BoxFit.fill),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}


