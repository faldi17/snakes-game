import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static List<int> snakePosition = [45, 65, 85, 105, 125];
  int numberOfSquares = 760;

  static final Random randomNumber = Random();
  int food = 0;
  var direction = 'down';

  @override
  void initState() {
    super.initState();
    generateNewFood();
  }

  void generateNewFood() {
    int newFood = randomNumber.nextInt(numberOfSquares);
    while (snakePosition.contains(newFood)) {
      newFood = randomNumber.nextInt(numberOfSquares);
    }
    setState(() => food = newFood);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (_) {},
              onHorizontalDragUpdate: (_) {},
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 760,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 20,
                ),
                itemBuilder: (context, index) {
                  if (snakePosition.contains(index)) {
                    return Container(
                      padding: EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(color: Colors.white),
                      ),
                    );
                  }
                  if (index == food) {
                    return Container(
                      padding: EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(color: Colors.red),
                      ),
                    );
                  }
                  return Container(
                    padding: EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(color: Colors.grey[900]),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Play', style: TextStyle(color: Colors.white)),
                Text('Exit', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
