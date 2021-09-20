import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../../../constants.dart';


class User {
  final String name, email;
  final int courses;

  User({this.name, this.email, this.courses});
}

class Users extends StatefulWidget {
  const Users({
    Key key,
  }) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  var isLoading = false;

  List usersList = [];

  storeUsers() async {
    setState(() {
      isLoading = true;
    });
    var users = await FirebaseFirestore.instance.collection('users').get();
    var user;
    for (var i = 0; i < users.docs.length; i++) {
      user = users.docs[i];
      setState(() {
        usersList.add(User(
            name: user['name'], email: user['email'], courses: 0));
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    storeUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Users",
            style: Theme.of(context).textTheme.headline5,
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox(
                  width: double.infinity,
                  child: DataTable2(
                    columnSpacing: defaultPadding,
                    minWidth: 600,
                    columns: [
                      DataColumn(
                        label: Text("Name"),
                      ),
                      DataColumn(
                        label: Text("Email"),
                      ),
                      // DataColumn(
                      //   label: Text("Courses"),
                      // ),
                    ],
                    rows: List.generate(
                      usersList.length,
                      (index) => userDataRow(usersList[index]),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  DataRow userDataRow(var userInfo) {
    return DataRow(
      cells: [
        DataCell(
          Text(userInfo.name),
        ),
        DataCell(Text(userInfo.email)),
        // DataCell(Text(userInfo.courses.toString())),
      ],
    );
  }
}
