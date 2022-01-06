import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.black),
      )
  );
}