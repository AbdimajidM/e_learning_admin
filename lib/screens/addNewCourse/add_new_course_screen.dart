import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_admin/screens/main/components/side_menu.dart';
import 'package:flutter/painting.dart'; // NetworkImage
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:e_learning_admin/Widgets/btn_widget.dart';
import 'package:e_learning_admin/Widgets/build_text_field.dart';
import 'package:e_learning_admin/api/firebase_api.dart';
import 'package:e_learning_admin/constants.dart';

class Lecture {
  String videoUrl;
  Lecture({this.videoUrl});
}

class AddNewCourse extends StatefulWidget {
  // This widget is the root of your application.

  @override
  State<AddNewCourse> createState() => _AddNewCourseState();
}

class _AddNewCourseState extends State<AddNewCourse> {
  CollectionReference courses =
      FirebaseFirestore.instance.collection('courses');
  var courseName;
  var author;
  var price;
  PlatformFile imgFile;
  String error;
  bool isLoading = false;
  var task1;
  var task2;

  List<PlatformFile> pickedLectures = [];

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

  void getImage() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    // html.File imageFile =
    //     await ImagePickerWeb.getImage(outputType: ImageType.file);
    if (result != null) {
      // BlobImage blobImage = new BlobImage(imageFile, name: imageFile.name);
      setState(() {
        // pickedImage = NetworkImage(blobImage.url);
        imgFile = result.files.first;
      });
    }
  }

  Widget displayImage() {
    if (imgFile == null) {
      return Text(
        'No Image Selected!',
      );
    } else {
      return Container(
        width: 200,
        child: Text(
          imgFile.name,
        ),
      );
    }
  }

  Future<void> getLectures() async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          pickedLectures.add(file);
        }
      });
    } else {
      // User canceled the picker
    }
  }

  void deleteLecture(int index) {
    setState(() {
      pickedLectures.removeAt(index);
    });
  }

  String getDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String date = formatter.format(now);
    return date;
  }

  Future<void> addCourse(courseName, author, imageUrl, lectures,price) {
    if (courseName != null && author != null)
      return courses.add({
        'name': courseName,
        'author': author,
        'price': price,
        'imageUrl': imageUrl,
        'lectures': lectures,
        'date': getDate(),
      }).catchError(
        (error) {
          print("Failed to add user: $error");
        },
      );
    return null;
  }

  Future registerCourse(context) async {
    try {
      setState(() {
        isLoading = true;
      });
      // when file selected
      if (imgFile != null &&
          courseName != null &&
          author != null &&
          price!=null &&
          pickedLectures.length != 0) {
        // upload image
        final fileName = basename(imgFile.name);
        final destination = 'courseImages/$fileName';
        task1 = FirebaseApi.uploadBytes(destination, imgFile.bytes);
        if (task1 == null) return;
        var snapshot = await task1.whenComplete(() {
          print('image upload completed');
        });

        var imageUrl = await snapshot.ref.getDownloadURL();

        // upload lectures
        List lectures = [];
        for (var i = 0; i < pickedLectures.length; i++) {
          // final fileName = basename(pickedLectures[i].name);
          var fileName = pickedLectures[i].name.split('.')[0];
          final destination = 'lectures/$fileName';
          task2 = FirebaseApi.uploadBytes(destination, pickedLectures[i].bytes);
          if (task2 == null) return;
          var snapshot = await task2.whenComplete(() {});
          lectures.add({
            'title': fileName,
            'videoUrl': await snapshot.ref.getDownloadURL(),
          });
        }

        print('videos uploaded');

        addCourse(courseName, author, imageUrl, lectures, price);
      } else {
        error = 'no blank space is allowed';
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'error $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add New Course'),
        backgroundColor: secondaryColor,
      ),
      body: Row(
        children: [
          Expanded(child: SideMenu()),
          Expanded(
            flex: 6,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 108.0, vertical: 50),
                        child: Container(
                          child: Column(
                            children: [
                              buildTextField(
                                hint: 'Enter course name',
                                type: 'courseName',
                                getValueFn: getTextFieldData,
                              ),
                              buildTextField(
                                hint: 'Enter author name',
                                type: 'author',
                                getValueFn: getTextFieldData,
                              ),
                              buildTextField(
                                hint: 'Enter course price',
                                type: 'price',
                                getValueFn: getTextFieldData,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  displayImage(),
                                  // Text("No image selected", style: kLabelStyle.copyWith(color: Colors.black),),
                                  ElevatedButton(
                                      onPressed: () {
                                        getImage();
                                      },
                                      child: Text("Upload Image")),
                                ],
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              Container(
                                width: 300,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    getLectures();
                                  },
                                  child: Text("Upload lectures"),
                                ),
                              ),
                              // ButtonSpecialWidget(text: 'Upload lectures'),
                              SizedBox(
                                height: 100,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 108.0),
                        child: Container(
                          child: Column(
                            children: [
                              Text(
                                "Uploaded Videos",
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              if (pickedLectures.length != null)
                                for (var i = 0; i < pickedLectures.length; i++)
                                  ListTile(
                                    title: Text(pickedLectures[i].name),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        deleteLecture(i);
                                      },
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                error != null
                    ? Center(
                        child: Text(
                          error,
                        ),
                      )
                    : SizedBox(),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 250, vertical: 20),
                  // width: 200,
                  child: ButtonWidget(
                    isLoading: isLoading,
                    btnText: 'SAVE',
                    onClick: () {
                      registerCourse(context);
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
