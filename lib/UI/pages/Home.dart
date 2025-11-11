import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String title;
  Home(this.title, {required String title}) : super();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 300,
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }


}