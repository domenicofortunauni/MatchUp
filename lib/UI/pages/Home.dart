import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  Home() : super();
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                ("welcome!"),
                style: TextStyle(
                  fontSize: 50,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Icon(
                Icons.sports_tennis_sharp,
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
