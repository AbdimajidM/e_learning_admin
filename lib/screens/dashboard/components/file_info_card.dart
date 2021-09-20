import 'package:e_learning_admin/models/MyFiles.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class FileInfoCard extends StatelessWidget {
  const FileInfoCard({
    Key key,
    this.info,
  }) : super(key: key);

  final CloudStorageInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            // padding: EdgeInsets.all(defaultPadding * 0.75),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(info.icon),
          ),
          Text(
            info.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${info.numOfFiles} ${info.title}",
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: Colors.white70),
          )
        ],
      ),
    );
  }
}

