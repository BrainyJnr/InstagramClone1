import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/users.dart';
import '../providers/user_providers.dart';

class CommentCard extends StatefulWidget {
  final snap;

  const CommentCard({super.key, required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final Users users = Provider.of<UserProvider>(context).getUser;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: users != null &&
                    users.photoUrl != null &&
                    users.photoUrl.isNotEmpty
                ? NetworkImage(users.photoUrl)
                : AssetImage('assets/image/IconImage-removebg-preview.png')
                    as ImageProvider,
            radius: 18,
          ),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: widget.snap["name"],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                          TextSpan(
                              text: " ${widget.snap["text"]}",
                              style: const TextStyle(color: Colors.white
                                  //fontWeight: FontWeight.bold
                                  ))
                        ])),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat.yMMMd()
                                .format(widget.snap["datePublished"].toDate()),
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ]))),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.favorite,
              size: 14,
            ),
          )
        ],
      ),
    );
  }
}
