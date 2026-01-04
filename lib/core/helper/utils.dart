import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Utils {


  // show snackbar
 static void toast(String title, String message, {bool isError = false}) {
    Toastification().show(
      title: Text(title),
      description: Text(message),
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.minimal,
      type: isError ? ToastificationType.error : ToastificationType.success,
    );
  } 

}