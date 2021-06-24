import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

class LockScreen extends StatefulWidget {
  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: this._textEditingController,
            ),
            ElevatedButton(
              child: Text('Go'),
              onPressed: () {
                if (this._textEditingController.text == '0000') {
                  AppLock.of(context).didUnlock('some data');
                }
              },
            ),
            ElevatedButton(
              child: Text('Go'),
              onPressed: () {
                Navigator.of(context).pushNamed('/my-second-page');
              },
            )
          ],
        ),
      ),
    );
  }
}
