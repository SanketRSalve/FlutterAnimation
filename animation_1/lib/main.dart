import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Example 1',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// HeartShape Clipper
class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double x = size.width;
    double y = size.height;

    Path path = Path();
    path.moveTo(0.5 * x, 0.35 * y);
    path.cubicTo(0.2 * x, 0.1 * y, -0.25 * x, 0.6 * y, 0.5 * x, y);
    path.moveTo(0.5 * x, 0.35 * y);
    path.cubicTo(0.8 * x, 0.1 * y, 1.25 * x, 0.6 * y, 0.5 * x, y);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0.0, end: 2 * pi).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5E1FE),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(_animation.value),
              child: ClipPath(
                clipper: HeartClipper(),
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0xffcff3fe),
                            offset: Offset(0.5, 0.5),
                            spreadRadius: 4.0,
                            blurRadius: 10.0),
                      ],
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFCA3B5), Color(0xFFFACDD6)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
