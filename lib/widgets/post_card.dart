import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_providers.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comment_screen.dart';
import 'package:instagram_clone/utilis/colors.dart';
import 'package:instagram_clone/utilis/global.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';



class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimation = false;
  int commentLength = 0;
  late Users user;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.snap["postId"])
          .collection("comments")
          .snapshots()
          .listen((snapshot) {
        setState(() {
          commentLength = snapshot.docs.length;
        });
      });
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final users = userProvider.getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
          ), color: mobileBackgroundColor),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with avatar and username
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Fetch the user's profile picture
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Instagram')
                      .doc(widget.snap['uid'])
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Loading indicator
                    } else if (userSnapshot.hasError) {
                      return const Icon(Icons.error); // Error if something goes wrong
                    } else if (userSnapshot.hasData && userSnapshot.data != null) {
                      var userDoc = userSnapshot.data!;
                      String photoUrl = userDoc['photoUrl'] ?? ''; // Fetch the photoUrl

                      // Display the user profile picture in a ClipOval widget
                      return ClipOval(
                        child: SizedBox(
                          width: 35,
                          height: 35,
                          child: CachedNetworkImage(fit: BoxFit.cover,
                            imageUrl: photoUrl, // Display the user's profile picture
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      );
                    } else {
                      return const Icon(Icons.account_circle); // Default icon if no photoUrl is found
                    }
                  },
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.snap["username"] ?? "Unknown User",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          children: ["Delete"].map((e) {
                            return InkWell(
                              onTap: () async {
                                await FirestoreMethods()
                                    .deletePost(widget.snap["postId"]);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Text(e),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Image section with like animation
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likedPost(
                  widget.snap["postId"].toString(), users.uid, widget.snap["likes"]);
              setState(() {
                isLikeAnimation = true;
              });

              // Reset the like animation state after animation
              Future.delayed(const Duration(milliseconds: 400), () {
                setState(() {
                  isLikeAnimation = false;
                });
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  widget.snap['postUrl'].toString(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35,
                ),
                if (isLikeAnimation)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLikeAnimation ? 1 : 0,
                    child: LikeAnimation(
                      isAnimating: isLikeAnimation,
                      duration: const Duration(milliseconds: 400),
                      onEnd: () {
                        setState(() {
                          isLikeAnimation = false;
                        });
                      },
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Like, Comment, and other actions
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap["likes"].contains(users.uid),
                smallLike: true,
                child: IconButton(
                  icon: widget.snap["likes"].contains(users.uid)
                      ? Icon(Icons.favorite, color: Colors.red)
                      : Icon(Icons.favorite_border),
                  onPressed: () async {
                    await FirestoreMethods().likedPost(
                        widget.snap["postId"], users.uid, widget.snap["likes"]);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.comment_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(snap: widget.snap),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {},
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
            ],
          ),

          // Description and Comment Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.snap["likes"].length} likes",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap["username"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${widget.snap["description"]}')
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "View all $commentLength comments",
                      style: TextStyle(fontSize: 14, color: secondaryColor),
                    ),
                  ),
                ),
                Text(
                  DateFormat.yMMMEd()
                      .format(widget.snap["datePublished"].toDate()),
                  style: TextStyle(fontSize: 14, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




class CachedImage extends StatelessWidget {
  String? imageURL;
  CachedImage(this.imageURL, {super.key});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: imageURL!,
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          child: Padding(
            padding: EdgeInsets.all(130),
            child: CircularProgressIndicator(
              value: progress.progress,
              color: Colors.black,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) => Container(
        color: Colors.amber,
      ),
    );
  }
}

