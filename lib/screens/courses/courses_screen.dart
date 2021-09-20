import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_admin/Widgets/build_text_field.dart';
import 'package:e_learning_admin/screens/addNewCourse/add_new_course_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_learning_admin/screens/main/components/side_menu.dart';

import '../../constants.dart';
import '../../responsive.dart';
import 'course_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key key}) : super(key: key);

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  var courseRef = FirebaseFirestore.instance.collection("courses");
  var courseName;
  var author;
  var price;

  void getTextFieldData({type, value}) {
    if (type == 'courseName') {
      setState(() {
        courseName = value;
      });
    } else if (type == 'author') {
      setState(() {
        author = value;
      });
    } else if (type == 'price') {
      setState(() {
        price = value;
      });
    } else {
      print('type is not recognized');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Courses"),
          centerTitle: true,
          backgroundColor: secondaryColor,
          actions: [
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewCourse(),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Add New Course"),
            ),
          ],
        ),
        body: Container(
            height: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: SideMenu(),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: EdgeInsets.all(50),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: courseRef.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          var courses = snapshot.data.docs;

                          return GridView.count(
                            crossAxisCount: 3,
                            children: List.generate(courses.length, (index) {
                              var course = courses[index];
                              var lectures = course['lectures'].length;
                              var enrolledUsers = 0;
                              try {
                                enrolledUsers = course['enrolledBy'].length;
                              } catch (e) {
                                enrolledUsers = 0;
                                print(e);
                              }

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CourseScreen(
                                          courseId: course.id,
                                          name: course['name'],
                                        ),
                                      ));
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [secondaryColor, secondaryColor],
                                      end: Alignment.bottomCenter,
                                      begin: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            course['imageUrl'].toString()),
                                        radius: 50,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        course['name'],
                                        style: kTitleTextStyle.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '\$${course['price']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),

                                      Text(
                                        'Created By ${course['author']}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        lectures != 1
                                            ? '$lectures lectures'
                                            : '$lectures lecture',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(1),
                                        color: bgColor,
                                        child: Text(
                                          enrolledUsers != 1
                                              ? '$enrolledUsers Students'
                                              : '$enrolledUsers Student',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(.9),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      //edit and delete button
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton.icon(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: defaultPadding,
                                              ),
                                            ),
                                            onPressed: () {
                                              edit(BuildContext context) {
                                                // set up the button
                                                Widget cancelButton =
                                                    TextButton(
                                                  child: Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                );
                                                Widget updateButton =
                                                    TextButton(
                                                  child: Text("Update"),
                                                  onPressed: () {
                                                    var newName =
                                                        courseName != null
                                                            ? courseName
                                                            : course['name'];
                                                    var newAuthor =
                                                        author != null
                                                            ? author
                                                            : course['author'];

                                                    var newPrice = price != null
                                                        ? price
                                                        : course['price'];

                                                    DocumentReference
                                                        documentReferencer =
                                                        courseRef
                                                            .doc(course.id);
                                                    documentReferencer.update({
                                                      'name': newName,
                                                      'author': newAuthor,
                                                      'price': newPrice,
                                                    }).then((value) {
                                                      final snackBar = SnackBar(
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        margin: EdgeInsets.only(
                                                            left: 225),
                                                        backgroundColor:
                                                            secondaryColor,
                                                        content: Text(
                                                          '${course['name']} course updated!',
                                                          style: TextStyle(
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                      );
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              snackBar);
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                );
                                                // set up the AlertDialog
                                                AlertDialog alert = AlertDialog(
                                                  backgroundColor:
                                                      secondaryColor,
                                                  title: Text(
                                                      "UPDATE COURSE INFO (${course['name']})"),
                                                  content: Container(
                                                    width: 300,
                                                    height: 210,
                                                    child: Column(
                                                      children: [
                                                        buildTextField(
                                                          hint: 'Course Name',
                                                          getValueFn:
                                                              getTextFieldData,
                                                          type: 'courseName',
                                                        ),
                                                        buildTextField(
                                                          hint: 'Author Name',
                                                          getValueFn:
                                                              getTextFieldData,
                                                          type: 'author',
                                                        ),
                                                        buildTextField(
                                                          hint: 'Course Price',
                                                          getValueFn:
                                                              getTextFieldData,
                                                          type: 'price',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    cancelButton,
                                                    updateButton,
                                                  ],
                                                );
                                                // show the dialog
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return alert;
                                                  },
                                                );
                                              }

                                              edit(context);
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              size: 15,
                                            ),
                                            label: Text("Edit"),
                                          ),
                                          ElevatedButton.icon(
                                            style: TextButton.styleFrom(
                                              backgroundColor: bgColor,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: defaultPadding,
                                              ),
                                            ),
                                            onPressed: () {
                                              confirmAndDelete(
                                                  BuildContext context) {
                                                // set up the button
                                                Widget cancelButton =
                                                    TextButton(
                                                  child: Text("No"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                );
                                                Widget deleteButton =
                                                    TextButton(
                                                  child: Text("Yes"),
                                                  onPressed: () {
                                                    courseRef
                                                        .doc(course.id)
                                                        .delete()
                                                        .then((value) {
                                                      print("Success!");
                                                    });
                                                    Navigator.pop(context);
                                                    final snackBar = SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      margin: EdgeInsets.only(
                                                          left: 225),
                                                      backgroundColor:
                                                          secondaryColor,
                                                      content: Text(
                                                        '${course['name']} course has deleted!',
                                                        style: TextStyle(
                                                            color:
                                                                CupertinoColors
                                                                    .white),
                                                      ),
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                  },
                                                );
                                                // set up the AlertDialog
                                                AlertDialog alert = AlertDialog(
                                                  backgroundColor:
                                                      secondaryColor,
                                                  title: Text(
                                                      "${course['name']} course"),
                                                  content: Text(
                                                      'do you really want do delete this course?'),
                                                  actions: [
                                                    cancelButton,
                                                    deleteButton,
                                                  ],
                                                );
                                                // show the dialog
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return alert;
                                                  },
                                                );
                                              }

                                              confirmAndDelete(context);
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              size: 15,
                                            ),
                                            label: Text("Delete"),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                  ),
                )
              ],
            )));
  }
}
