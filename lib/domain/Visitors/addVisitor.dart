import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:school_erp/config/Colors.dart';
import 'package:school_erp/domain/authentication/widgets/ResuableWidgets.dart';
import 'package:school_erp/shared/functions/popupSnakbar.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class AddVisitor extends StatefulWidget {
  const AddVisitor({Key? key}) : super(key: key);

  @override
  State<AddVisitor> createState() => _addVisitor();
}


class _addVisitor extends State<AddVisitor> {
  final _formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final messageController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();


  late File _pickedImage;
  late CameraController _controller;
  CollectionReference visitors = FirebaseFirestore.instance.collection('visitor');

  Map<String, dynamic> visitorData ={
    "Name":"",
    "Phone":"",
    "Email":"",
    "Address":"",
    "Reason":"",
    "VisitTime":DateTime.now().millisecondsSinceEpoch,

  };
  addVisitor() {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()){
      print('Visitor Add in DataBase');
    }
  }
  String imageUrl = '';


  @override
  void dispose() {
    displayNameController.dispose();
    emailController.dispose();
    messageController.dispose();
    addressController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: loginColor1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: loginButtonTextColor,
            shadows: [
              Shadow(color: loginIconColor,blurRadius: 100)
            ],
          ),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                loginColor1, loginColor2, loginColor3,
              ],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            )
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.001002, 20, 0),
              child: Column(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 30),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              ImagePicker imagePicker=ImagePicker();
                              XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
                              print('${file?.path}');
                              print(imagePicker);
                              if (file ==null) return;
                              String UniqueImageName = DateTime.now().millisecondsSinceEpoch.toString();
                              Reference referenceRoot = FirebaseStorage.instance.ref();
                              Reference referenceDirImages = referenceRoot.child('images');
                              Reference referenceImageToUpload = referenceDirImages.child(UniqueImageName);
                              try{
                                await referenceImageToUpload.putFile(File(file!.path));
                                imageUrl= await referenceImageToUpload.getDownloadURL();
                              }catch(error){ }
                            },
                            child: const CircleAvatar(radius: 71,
                              backgroundColor: loginButtonTextColor,
                              child: CircleAvatar(
                                radius: 65,


                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    validator: ( msg) {
                      if(msg!.isEmpty) {
                        return "Enter a valid name";
                      }
                      return null;

                    } ,
                    controller: displayNameController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: loginIconColor,
                      ),
                      labelText: 'Name',
                      labelStyle:
                      TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.solid,
                              color: loginIconColor)),
                    ),

                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    validator: ( number) {
                      if(number!.isEmpty) {
                        return "Enter a valid Number";
                      }
                      return null;

                    } ,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.call,
                        color: loginIconColor,
                      ),
                      labelText: 'Phone Number',
                      labelStyle:
                      TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.solid,
                              color: loginIconColor)),
                    ),

                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: loginIconColor,
                      ),
                      labelText: 'Email Id',
                      labelStyle:
                      TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.solid,
                              color: loginIconColor)),
                    ),

                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    validator: ( msg) {
                      if(msg!.isEmpty) {
                        return "Enter valid Address";
                      }
                      return null;

                    } ,
                    controller: addressController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.home_outlined,
                        color: loginIconColor,
                      ),
                      labelText: 'Address',
                      labelStyle:
                      TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.solid,
                              color: loginIconColor)),
                    ),

                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    validator: ( msg) {
                      if(msg!.isEmpty) {
                        return "Enter valid Reason";
                      }
                      return null;

                    } ,
                    controller: messageController,
                    textInputAction: TextInputAction.next,
                    cursorColor: loginButtonColor,
                    style: TextStyle(color: loginTextColor.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.edit_note,
                        color: loginIconColor,
                      ),
                      labelText: 'Reason',
                      labelStyle:
                      TextStyle(color: loginTextColor.withOpacity(0.9)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.solid,
                              color: loginIconColor)),
                    ),
                    maxLines: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: loginButtonTextColor,
          onPressed: () {
            if (imageUrl!.isEmpty){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please Click an Image First')));
            } else {
              return;
            }
            if (_formKey.currentState!.validate()) {
              FirebaseFirestore.instance.collection('messages').add({
                'name': displayNameController.text,
                'email': emailController.text,
                'message': messageController.text,
                'timestamp': DateTime.now(),
              });
              displayNameController.clear();
              emailController.clear();
              messageController.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Visitor add successfully'),
                duration: Duration(seconds: 2),
              ));
            }
            FirebaseFirestore.instance.collection('Visitors_data').add(visitorData);
          },
          child: const Icon(Icons.done, size: 50,)

      ),
    );
  }
}
