import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<void> saveAndlaunchfile(List<int> bytes,String filename) async
{
  //final path=(await getTemporaryDirectory()).path;
  if (await Permission.storage.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    var path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    // final path= Directory("storage/emulated/0/AdminFitlance");
    // if ((await path.exists())){
    // }else{
    //   path.create();
    // }
    final file=File('$path/$filename');
    await file.writeAsBytesSync(bytes,flush: true);
    OpenFile.open('$path/$filename');
    Fluttertoast.showToast(
      msg: "Your file saved download folder",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: Colors.black.withOpacity(0.8),
      fontSize: 14.0,
    );
  }
  else
    {
      Fluttertoast.showToast(
        msg: "Allow storage permission permission",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.black.withOpacity(0.8),
        fontSize: 14.0,
      );
    }

}

