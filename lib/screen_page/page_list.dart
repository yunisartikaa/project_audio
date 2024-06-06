import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'page_detail.dart';
import '../model/user_model.dart';

class PageListUser extends StatefulWidget {
  const PageListUser({super.key});

  @override
  State<PageListUser> createState() => _PageListUserState();
}

class _PageListUserState extends State<PageListUser> {
  bool isLoading = false;
  List<ModelUser> listUser = [];
  List<ModelUser> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUsers();
    searchController.addListener(_searchUsers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _searchUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = listUser.where((user) {
        return user.firstName!.toLowerCase().contains(query) ||
            user.lastName!.toLowerCase().contains(query) ||
            user.email!.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future getUsers() async {
    try {
      setState(() {
        isLoading = true;
      });

      http.Response response1 = await http.get(Uri.parse("https://reqres.in/api/users"));
      var data1 = jsonDecode(response1.body);

      http.Response response2 = await http.get(Uri.parse("https://reqres.in/api/users?page=2"));
      var data2 = jsonDecode(response2.body);

      setState(() {
        for (Map<String, dynamic> i in data1['data']) {
          listUser.add(ModelUser.fromJson(i));
        }
        for (Map<String, dynamic> i in data2['data']) {
          listUser.add(ModelUser.fromJson(i));
        }
        filteredUsers = listUser;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()))
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('List User'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(filteredUsers[index].avatar ?? ""),
                        radius: 30,
                        onBackgroundImageError: (_, __) => Icon(Icons.error, color: Colors.red),
                      ),
                      title: Text(
                        '${filteredUsers[index].firstName} ${filteredUsers[index].lastName}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        "Email: ${filteredUsers[index].email}",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageDetailUser(user: filteredUsers[index]),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}