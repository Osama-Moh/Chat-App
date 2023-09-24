import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Userimagepicker extends StatefulWidget {
  const Userimagepicker({super.key, required this.onpickimage});

  final void Function (File pickedimage) onpickimage; 

  @override
  State<Userimagepicker> createState() {
    return _UserimagepickerState();
  }
}

class _UserimagepickerState extends State<Userimagepicker> {
  
  File? _pickedimagefile;

  void _pickimage() async 
  {
    final pickedimage = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    //final pickedimage1 = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 150); 

    if (pickedimage == null) //(pickedimage == null && pickedimage1 == null)
    {
      return;
    }
    setState(() {
      _pickedimagefile = File(pickedimage.path);
    });
    widget.onpickimage(_pickedimagefile!);
  }
   
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedimagefile != null ? FileImage(_pickedimagefile!) : null,
        ),
        TextButton.icon(
          onPressed: _pickimage,
          icon: const Icon(Icons.image),
          label: Text('Add Image', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
        ),
      ],
    );
  }
}
