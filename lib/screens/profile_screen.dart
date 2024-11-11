import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import '../models/post.dart';
import '../models/users.dart';
import '../resources/auth_methods.dart';
import '../utilis/colors.dart';
import '../utilis/utilis.dart';
import '../widgets/follow_button.dart';
import 'login_screens.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Users user;
  late Post post;
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      // Fetch the user document
      var userSnapshot = await FirebaseFirestore.instance
          .collection('Instagram')
          .doc(widget.uid)
          .get();

      if (userSnapshot.exists) {
        user = Users.fromSnap(userSnapshot);
        setState(() {});

        // Check and update `profileImage` in each of the user's posts if necessary
        var postsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where(widget.uid)
            .get();

        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var postDoc in postsSnapshot.docs) {
          if (!postDoc.data().containsKey('profileImage')) {
            batch.update(postDoc.reference, {
              'profileImage': user.photoUrl,
              // Ensure `profileImage` is up-to-date
              'profileImages': post.profileImage,
              // Ensure `profileImage` is up-to-date
            });
          }
        }

        // Commit any necessary updates
        if (batch != null) {
          await batch.commit();
        }
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Instagram')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(
        e.toString(),
        context,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateProfilePicture() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      // Upload the new image to Firebase Storage
      String filePath = 'profilePictures/${user.uid}/${DateTime.now()}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      await storageRef.putFile(File(image.path));
      String newPhotoUrl = await storageRef.getDownloadURL();

      // Update photoUrl in the user's main profile document
      await FirebaseFirestore.instance
          .collection('Instagram')
          .doc(user.uid)
          .update({
        'photoUrl': newPhotoUrl,
      });

      // Update each post's profileImage field in a batch operation
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(user.uid)
          .update({
        'profileImage': newPhotoUrl,
      });


      print('Profile image updated successfully!');
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
            ),
            body: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Instagram')
                  .doc(widget
                      .uid) // Make sure you're listening to the right user
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text("No user data available"),
                  );
                }

                // Fetch user data from the Firestore snapshot
                var userData = snapshot.data!.data() as Map<String, dynamic>;

                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Profile Picture and Camera Icon to Update Photo
                              GestureDetector(
                                onTap: updateProfilePicture,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      NetworkImage(userData['photoUrl']),
                                  radius: 40,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildStatColumn(postLen, "posts"),
                                        buildStatColumn(followers, "followers"),
                                        buildStatColumn(following, "following"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        FirebaseAuth.instance.currentUser!
                                                    .uid ==
                                                widget.uid
                                            ? FollowButton(
                                                text: 'Sign Out',
                                                backgroundColor:
                                                    mobileBackgroundColor,
                                                textColor: primaryColor,
                                                borderColor: Colors.grey,
                                                function: () async {
                                                  await AuthMethods().signOut();
                                                  if (context.mounted) {
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const LoginScreen(),
                                                      ),
                                                    );
                                                  }
                                                },
                                              )
                                            : isFollowing
                                                ? FollowButton(
                                                    text: 'Unfollow',
                                                    backgroundColor:
                                                        Colors.white,
                                                    textColor: Colors.black,
                                                    borderColor: Colors.grey,
                                                    function: () async {
                                                      await FirestoreMethods()
                                                          .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData['uid'],
                                                      );

                                                      setState(() {
                                                        isFollowing = false;
                                                        followers--;
                                                      });
                                                    },
                                                  )
                                                : FollowButton(
                                                    text: 'Follow',
                                                    backgroundColor:
                                                        Colors.blue,
                                                    textColor: Colors.white,
                                                    borderColor: Colors.blue,
                                                    function: () async {
                                                      await FirestoreMethods()
                                                          .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData['uid'],
                                                      );

                                                      setState(() {
                                                        isFollowing = true;
                                                        followers++;
                                                      });
                                                    },
                                                  )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              userData['username'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(userData['bio']),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: widget.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: (snapshot.data! as dynamic).docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 1.5,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            DocumentSnapshot snap =
                                (snapshot.data! as dynamic).docs[index];

                            return SizedBox(
                              child: Image(
                                image: NetworkImage(snap['postUrl']),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                );
              },
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
