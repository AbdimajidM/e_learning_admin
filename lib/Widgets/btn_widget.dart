import 'package:flutter/material.dart';
import 'package:e_learning_admin/constants.dart';
// ignore: must_be_immutable
class ButtonWidget extends StatelessWidget {
  var btnText = '';
  Color color;
  var onClick;
  bool isLoading;

  ButtonWidget({this.isLoading,this.btnText, this.onClick, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child:Container(
        margin: EdgeInsets.only(top: 5),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [primaryColor,primaryColor],
              end: Alignment.centerLeft,
              begin: Alignment.centerRight),
          borderRadius: BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        alignment: Alignment.center,
        child:isLoading ? CircularProgressIndicator(backgroundColor: secondaryColor,) : Text(
          btnText,
          style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
