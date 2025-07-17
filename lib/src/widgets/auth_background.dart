import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff2E305F),
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: <Widget>[_HeaderIcon(), child],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 30.0),
        child: const Icon(Icons.person_pin, color: Colors.white, size: 125),
      ),
    );
  }
}

// colors: [
//             Color(0xff2E305F),
//             Color(0xff202333),
//           ],
