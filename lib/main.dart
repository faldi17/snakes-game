import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show exit, Platform;
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
      debugShowCheckedModeBanner: false,
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
  // Initial snake body positions (indexes of the grid)
  static List<int> snakePosition = [45, 65, 85, 105, 125];
  // Total number of grid squares (20 x 38)
  int numberOfSquares = 760;

  // Random number generator for food location
  static final Random randomNumber = Random();
  // Current food position
  int food = 0;
  // Current movement direction
  var direction = 'down';

  @override
  void initState() {
    super.initState();
    generateNewFood(); // Spawn first food
  }

  // Create new food position that does not overlap with the snake body
  void generateNewFood() {
    int newFood = randomNumber.nextInt(numberOfSquares);
    while (snakePosition.contains(newFood)) {
      newFood = randomNumber.nextInt(numberOfSquares);
    }
    setState(() => food = newFood);
  }

  // Start the game: reset snake, direction, and begin timer
  void startGame() {
    setState(() {
      snakePosition = [45, 65, 85, 105, 125];
      direction = 'down';
    });

    generateNewFood();

    // Game loop (moves snake every 300ms)
    const duration = Duration(milliseconds: 300);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver()) {
        timer.cancel();
        _showGameOverScreen(); // Display Game Over dialog
      }
    });
  }

  // Update snake position based on current direction
  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          // Wrap from bottom to top
          if (snakePosition.last > numberOfSquares - 20) {
            snakePosition.add(snakePosition.last + 20 - numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break;

        case 'up':
          // Wrap from top to bottom
          if (snakePosition.last < 20) {
            snakePosition.add(snakePosition.last - 20 + numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;

        case 'left':
          // Wrap from left edge to right edge
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(snakePosition.last - 1 + 20);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;

        case 'right':
          // Wrap from right edge to left edge
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(snakePosition.last + 1 - 20);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;

        default:
      }

      // If snake eats food, generate new food
      if (snakePosition.last == food) {
        generateNewFood();
      } else {
        // Otherwise remove the tail (snake moves forward)
        snakePosition.removeAt(0);
      }
    });
  }

  // Check if snake hits itself (self-collision)
  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) count++;
        if (count == 2) return true; // A position appears twice -> collision
      }
    }
    return false;
  }

  // Display "Game Over" popup
  void _showGameOverScreen() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('GAME OVER'),
        content: Text('Your score: ${snakePosition.length - 5}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              startGame(); // Restart game
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  // Safely close the app (Android/iOS only; Web cannot exit)
  void _closeApp() {
    if (kIsWeb) return;
    try {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    } catch (e) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Game area
          Expanded(
            child: GestureDetector(
              // Detect vertical swipes
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },

              // Detect horizontal swipes
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },

              // 20x38 grid for the game board
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 760,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 20,
                ),

                // Render snake, food, or empty tile
                itemBuilder: (context, index) {
                  if (snakePosition.contains(index)) {
                    // Snake body
                    return Container(
                      padding: EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(color: Colors.white),
                      ),
                    );
                  }
                  if (index == food) {
                    // Food tile
                    return Container(
                      padding: EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(color: Colors.red),
                      ),
                    );
                  }
                  // Empty tile
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

          // Play and Exit buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: startGame,
                  child: const Text(
                    'P l a y',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                GestureDetector(
                  onTap: _closeApp,
                  child: const Text(
                    'E x i t',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
