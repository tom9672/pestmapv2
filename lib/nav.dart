import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/myData.dart';
import 'pages/map.dart';

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  int index = 0;
  List title = ['Take Photos', 'Pest Map', 'Current Data'];
  List body = [MyCamera(), MyMap(), Details()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('${title[this.index]}'),
      ),
      body: body[this.index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this.index,
        onTap: (index) {
          setState(() {
            this.index = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Data')
        ],
      ),
    );
  }
}
