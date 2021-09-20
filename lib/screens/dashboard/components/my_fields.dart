import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_admin/models/MyFiles.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'file_info_card.dart';



class MyFiles extends StatelessWidget {
  const MyFiles({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: defaultPadding),
        FileInfoCardGridView(
          childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
        ),
      ],
    );
  }
}



class FileInfoCardGridView extends StatefulWidget {
  const FileInfoCardGridView({
    Key key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  State<FileInfoCardGridView> createState() => _FileInfoCardGridViewState();
}

class _FileInfoCardGridViewState extends State<FileInfoCardGridView> {
  List demoMyFiles = [];
  bool isLoading = false;
  getContent() async {
    setState(() {
      isLoading = true;
    });
    var users = await FirebaseFirestore.instance.collection('users').get();
    var courses = await FirebaseFirestore.instance.collection('courses').get();
    setState(() {
      demoMyFiles.add(
        CloudStorageInfo(
          title: "Users",
          numOfFiles: users.docs.length,
          icon: Icons.people,
          color: Color(0xFF007EE5),
        ),
      );

      demoMyFiles.add(
        CloudStorageInfo(
          title: "Courses",
          numOfFiles: courses.docs.length,
          icon: Icons.school,
          color: Color(0xFF007EE5),
        ),
      );
    });
    setState(() {
      isLoading = false;
    });
  }

  @override

  void initState() {
    super.initState();
    getContent();
  }
  Widget build(BuildContext context) {
    return isLoading ? Center(child: CircularProgressIndicator(),) :  GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: demoMyFiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(info: demoMyFiles[index]),
    );
  }
}
