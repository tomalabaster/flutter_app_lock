import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({
    Key key,
  }) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();

    this._textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    this._textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              key: Key('PasswordField'),
              controller: this._textEditingController,
            ),
            ElevatedButton(
              key: Key('UnlockButton'),
              child: Text('Go'),
              onPressed: () {
                if (this._textEditingController.text == '0000') {
                  AppLock.of(context).didUnlock('some data');
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
