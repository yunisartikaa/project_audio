import 'package:flutter/material.dart';
import '../model/user_model.dart';

class PageDetailUser extends StatelessWidget {
  final ModelUser user;

  const PageDetailUser({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.firstName} ${user.lastName}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.avatar ?? ""),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'First Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user.firstName ?? "",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Last Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user.lastName ?? "",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Email:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email ?? "",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}