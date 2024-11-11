import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String username;
  final String email;
  final String uid;
  final String photoUrl;
  final String bio;
  final List followers;
  final List following;

  const Users({required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following});

  factory Users.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;

    return Users(
      uid: data['uid'] ?? '',
      // Provide a fallback value if the field is missing
      username: data['username'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      followers: data['followers'] ?? '',
      following: data['following'] ?? '',
    );
  }


Users copyWith({
  String? username,
  String? email,
  String? uid,
  String? photoUrl,
  String? bio,
  List? followers,
  List? following,
}) {
  return Users(
    username: username ?? this.username,
    uid: uid ?? this.uid,
    email: email ?? this.email,
    photoUrl: photoUrl ?? this.photoUrl,
    bio: bio ?? this.bio,
    followers: followers ?? this.followers,
    following: following ?? this.following,
  );
}


static Users fromSnap
(
DocumentSnapshot snap) {
var snapshot = snap.data() as Map<String, dynamic>;

return Users(
username: snapshot["username"],
uid: snapshot["uid"],
email: snapshot["email"],
photoUrl: snapshot["photoUrl"],
bio: snapshot["bio"],
followers: snapshot["followers"],
following: snapshot["following"],
);
}

Map<String, dynamic> toJson() => {
"username": username,
"uid": uid,
"email": email,
"photoUrl": photoUrl,
"bio": bio,
"followers": followers,
"following": following,
};
}

