import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_admin/api/firebase_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_learning_admin/screens/main/components/side_menu.dart';

import '../../constants.dart';
import '../../responsive.dart';

class CourseScreen extends StatefulWidget {
  final String courseId;
  final String name;
  const CourseScreen({this.courseId, this.name, Key key}) : super(key: key);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  var courseRef = FirebaseFirestore.instance.collection("courses");
  List dummyLectures = [];
  List lectures = [];
  var isLoading = false;
  var saving = false;
  var task1;

  List<Map> pickedLectures = [];

  Future<void> getLectures() async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);
    if (result != null) {
      setState(() {
        for (var file in result.files) {
          var id = UniqueKey();

          pickedLectures.add({
            'id': id,
            'file': file,
          });

          dummyLectures.add({
            'title': file.name.split('.')[0],
            'new': true,
            'id': id,
          });
        }
      });
    } else {
      // User canceled the picker
    }
  }

  Future updateLectures(context) async {
    try {
      setState(() {
        saving = true;
      });

      // upload lectures
      var course = await courseRef.doc(widget.courseId).get();

      for(var i = 0; i < dummyLectures.length; i++){
        print(lectures.length);

        var lecture = dummyLectures[i];
        if(lecture['new']==null){
          lectures.add(lecture);
        }

        print(lectures.length);
      }


      for (var i = 0; i < pickedLectures.length; i++) {
        var fileName = pickedLectures[i]['file'].name.split('.')[0];
        final destination = 'lectures/$fileName';
        task1 = FirebaseApi.uploadBytes(destination, pickedLectures[i]['file'].bytes);
        if (task1 == null) return;
        var snapshot = await task1.whenComplete(() {});
        lectures.add({
          'title': fileName,
          'videoUrl': await snapshot.ref.getDownloadURL(),
        });
      }

      print('videos uploaded');
      DocumentReference documentReferencer = courseRef.doc(course.id);
      documentReferencer
          .update({'lectures': lectures}).then((value) => print('updated'));

      setState(() {
        saving = false;
        getCourse();
        lectures = [];
      });

      pickedLectures = [];
      
    } catch (e) {
      setState(() {
        saving = false;
      });
    }

  }

  Future<void> getCourse() async {
    setState(() {
      isLoading = true;
    });
    // DocumentReference documentReferencer = courseRef.doc(widget.courseId);
    // print(documentReferencer.id);
    print(widget.courseId);
    var course = await courseRef.doc(widget.courseId).get();
    dummyLectures = course['lectures'];
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getCourse();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.name} Lectures"),
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
              getLectures();
            },
            icon: Icon(Icons.upload),
            label: Text("Add New Lecture"),
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
            // lectures in the database
            Expanded(
              flex: 3,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                      child: ListView.builder(
                        itemCount: dummyLectures.length + 1,
                        itemBuilder: (BuildContext context, int index) {


                          if (index == dummyLectures.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50.0, vertical: 50),
                              child: ElevatedButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding * 1.5,
                                    vertical: defaultPadding /
                                        (Responsive.isMobile(context)
                                            ? 2
                                            : 1),
                                  ),
                                ),
                                onPressed: () {
                                  updateLectures(context);
                                },
                                child: saving
                                    ? Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    ))
                                    : Text("SAVE"),
                              ),
                            );
                          }
                          var lecture = dummyLectures[index];
                          return ListTile(
                            title: Text(lecture['title']),
                            leading: lecture['new'] != null
                                ? Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Text(
                                "New",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                                : null,
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  dummyLectures.removeAt(index);
                                  if(lecture['new']!=null){
                                    pickedLectures.removeWhere((element) => element['id'] == lecture['id']);
                                  }
                                });
                              },
                              icon: Icon(Icons.delete),
                            ),
                          );

                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
