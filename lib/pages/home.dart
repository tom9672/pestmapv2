import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class MyCamera extends StatefulWidget {
  MyCamera({Key key}) : super(key: key);

  @override
  _MyCameraState createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  @override
  void initState() {
    super.initState();
    this.loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: 'assets/tflite/model_unquant.tflite',
        labels: 'assets/tflite/labels.txt',
      );
      print(res);
    } on PlatformException {
      print("Failed to load model");
    }
  }

  Future predictImage(File image) async {
    if (image == null) {
      print('no image');
    } else {
      await recognizeImage(image);
    }
  }

  Future recognizeImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print(recognitions);
  }

  ///Create variables for storing the position and the address, in the state class.
  Position _currentPosition;
  String _currentAddress;

  /// image picker and shou image
  File _image;
  final picker = ImagePicker();

  Future _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  int _amountPest;
  String _typePest;

  ///Instantiate the geolocator class.
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              margin: EdgeInsets.all(10.0),
              height: 300.0,
              width: 300.0,
              child: Center(
                child: _image == null
                    ? Text('No image selected.')
                    : Image.file(_image),
              )),
          Container(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.location_on),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Location',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            if (_currentPosition != null &&
                                _currentAddress != null)
                              Text(_currentAddress),
                            if (_currentPosition != null &&
                                _currentAddress != null)
                              Text('$_currentPosition'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ],
              )),
          SizedBox(
            height: 3.0,
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.pest_control),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Pest Information',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            if (_amountPest != null && _typePest != null)
                              Text('Amount: $_amountPest'),
                            if (_amountPest != null && _typePest != null)
                              Text('Type: $_typePest'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ],
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                child: Center(
                  child: FlatButton(
                    onPressed: () {
                      this._getImage();
                      this._getCurrentLocation();
                    },
                    child: Text('Camera'),
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              Container(
                child: FlatButton(
                  onPressed: () {
                    this._amountPest = 0;
                    this._typePest = 'Snail';

                    this.predictImage(this._image);
                  },
                  child: Text('Analyze'),
                  color: Colors.blueAccent,
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Center(
                  child: FlatButton(
                    onPressed: () {
                      this._addPestData();
                    },
                    child: Text('Add Data'),
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Create a CollectionReference called users that references the firestore collection
  CollectionReference pestData =
      FirebaseFirestore.instance.collection('pestData');

  Future<void> _addPestData() {
    // Call the user's CollectionReference to add a new user
    return pestData
        .add({
          'address': this._currentAddress,
          'position': '$_currentPosition',
          'typeOfPest': this._typePest,
          'amountOfPest': this._amountPest
        })
        .then((value) => print("Data Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
