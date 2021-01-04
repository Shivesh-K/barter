import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';

import 'package:barter/services/location.dart';
import 'package:barter/services/bart.dart';
import 'package:barter/services/permission.dart';

class NewBartScreen extends StatefulWidget {
  @override
  _NewBartScreenState createState() => _NewBartScreenState();
}

class _NewBartScreenState extends State<NewBartScreen> {
  final _geo = Geoflutterfire();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _photos = [];
  List<Asset> _selectedAssets = [];
  LocationData _locationData;

  String _titleError;

  @override
  void initState() {
    // (() async => _locationData = await LocationService.getCurrentLocation())();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "New Bart",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .merge(TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  autocorrect: true,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    errorText: _titleError,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: TextField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(16),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  children: List.generate(
                    10,
                    (i) => _imageBox(i < _photos.length ? _photos[i] : null),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Row(children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 8),
                  Text("Current location will be used"),
                ]),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      onPressed: _cleanup,
                      child: Text(
                        "Clear",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    RaisedButton(
                      onPressed: _submit,
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }

  Widget _imageBox(File image) {
    double side = MediaQuery.of(context).size.width / 5 - 8;
    return Container(
      height: side,
      width: side,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: image != null
          ? Stack(
              alignment: Alignment.center,
              children: [
                Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () => _removeImage(image),
                  color: Colors.red,
                )
              ],
            )
          : Center(
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: _pickImages,
              ),
            ),
    );
  }

  void _pickImages() async {
    if (!(await PermissionService.getPicturePermission())) return;

    List<Asset> imageAssets = _selectedAssets;
    try {
      imageAssets = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: _selectedAssets,
      );
    } catch (e) {
      print("There was an exception!");
    }

    List<String> paths = [];
    for (int i = 0; i < imageAssets.length; ++i) {
      final x =
          await FlutterAbsolutePath.getAbsolutePath(imageAssets[i].identifier);
      paths.add(x);
    }

    setState(() {
      _selectedAssets = imageAssets;
      _photos = paths.map((e) => File(e)).toList();
    });
  }

  void _removeImage(File image) {
    setState(() {
      final int i = _photos.indexOf(image);
      _selectedAssets.removeAt(i);
      _photos.removeAt(i);
    });
  }

  void _submit() async {
    _locationData = await LocationService.getCurrentLocation();

    if (_locationData == null) return;

    if (_titleController.text.trim() == '') {
      setState(() {
        _titleError = "The title cannot be empty!";
      });
      return;
    }

    if (_photos.length == 0 || _locationData == null) return;

    await Bart.create(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      photos: _photos,
      location: _geo.point(
        latitude: _locationData.latitude,
        longitude: _locationData.longitude,
      ),
    );
    _cleanup();
  }

  void _cleanup() {
    setState(() {
      _titleController.text = '';
      _descriptionController.text = '';
      _photos.removeWhere((e) => true);
    });
  }
}
