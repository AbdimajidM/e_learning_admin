import 'package:flutter/material.dart';

class CloudStorageInfo {
  final String title, totalStorage;
  final IconData icon;
  final int numOfFiles, percentage;
  final Color color;

  CloudStorageInfo({
    this.icon,
    this.title,
    this.totalStorage,
    this.numOfFiles,
    this.percentage,
    this.color,
  });
}


