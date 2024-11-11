import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utilis/colors.dart';
import 'package:instagram_clone/utilis/global.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/users.dart';
import '../providers/user_providers.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Users users = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(labelText: "Search for a user"),
          onFieldSubmitted: (String _) {
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("Instagram")
                  .where(
                    "username",
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                    uid: (snapshot.data! as dynamic).docs[index]
                                        ["uid"]))),
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                (snapshot.data! as dynamic).docs[index]
                                    ['photoUrl'],
                              ),
                              radius: 16,
                            ),
                            title: Text((snapshot.data! as dynamic).docs[index]
                                ['username'])),
                      );
                    });
              })
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection("posts").get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: const CircularProgressIndicator(),
                  );
                }

                if (screenWidth > webScreenSize) {
                  // Show ListView on larger screens
                  return GridView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    //physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      // mainAxisExtent: mainAxisExtent,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                    ),
                    itemBuilder: (context, index) => Image.network(
                      (snapshot.data! as dynamic).docs[index]['postUrl'],
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  // Show MasonryGridView on mobile
                  return MasonryGridView.count(
                    crossAxisCount: 3,
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) => Image.network(
                      (snapshot.data! as dynamic).docs[index]['postUrl'],
                      fit: BoxFit.cover,
                    ),
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  );
                }
              },
            ),
    );
  }
}
