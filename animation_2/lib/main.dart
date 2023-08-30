import 'dart:js_interop';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

extension on VoidCallback {
  Future<void> delayed(Duration duration) {
    return Future.delayed(duration, this);
  }
}

enum CircleSide { right, left }

extension ToPath on CircleSide {
  Path toPath(Size size) {
    var path = Path();
    late Offset _offset;
    late bool clockwise;
    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        _offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        _offset = Offset(0, size.height);
        clockwise = true;
        break;
    }
    path.arcToPoint(_offset,
        radius: Radius.elliptical(size.width / 2, size.height / 2),
        clockwise: clockwise);
    path.close();
    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  const HalfCircleClipper({required this.side});
  final CircleSide side;
  @override
  getClip(Size size) => side.toPath(size);

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => true;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _counterClockWiseRotationController;
  late AnimationController _flipAnimationController;
  late Animation _counterClockWiseAnimation;
  late Animation _flipAnimation;

  @override
  void initState() {
    super.initState();

    // Counter clockwise Animation
    _counterClockWiseRotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _counterClockWiseAnimation = Tween(begin: 0, end: -(pi / 2)).animate(
        CurvedAnimation(
            parent: _counterClockWiseRotationController,
            curve: Curves.bounceOut));
    // flip Animation
    _flipAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _flipAnimation = Tween(begin: 0, end: pi).animate(CurvedAnimation(
        parent: _flipAnimationController, curve: Curves.bounceOut));

    // Status Listener CounterClockWise
    _counterClockWiseAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipAnimation =
            Tween(begin: _flipAnimation.value, end: _flipAnimation.value + pi)
                .animate(CurvedAnimation(
                    parent: _flipAnimationController, curve: Curves.bounceOut));
        _flipAnimationController
          ..reset()
          ..forward();
      }
    });

    // Status Listener FlipAnimation
    _flipAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _counterClockWiseAnimation = Tween(
                begin: _counterClockWiseAnimation.value,
                end: _counterClockWiseAnimation.value + (-pi / 2))
            .animate(CurvedAnimation(
                parent: _counterClockWiseRotationController,
                curve: Curves.bounceOut));

        _counterClockWiseRotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    _counterClockWiseRotationController.dispose();
    _flipAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _counterClockWiseRotationController
      ..reset()
      ..forward.delayed(Duration(seconds: 1));
    return Scaffold(
      body: Center(
        child: ClipPath(
          child: AnimatedBuilder(
            animation: _counterClockWiseAnimation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(_counterClockWiseAnimation.value),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.centerRight,
                            transform: Matrix4.identity()
                              ..rotateY(_flipAnimation.value),
                            child: ClipPath(
                              clipper: HalfCircleClipper(side: CircleSide.left),
                              child: Container(
                                height: 200,
                                width: 200,
                                color: Color(0xff4ae4e6),
                              ),
                            ),
                          );
                        }),
                    AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.centerLeft,
                            transform: Matrix4.identity()
                              ..rotateY(_flipAnimation.value),
                            child: ClipPath(
                              clipper:
                                  HalfCircleClipper(side: CircleSide.right),
                              child: Container(
                                height: 200,
                                width: 200,
                                color: Color(0xff2bbffd),
                              ),
                            ),
                          );
                        })
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
