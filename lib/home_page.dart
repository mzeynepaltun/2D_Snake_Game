import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final int squaresPerRow = 20;
  final int squaresPerCol = 30;
  final fontStyle = const TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();

  var snake = [
    [0, 2],
    [0, 1],
    [0, 0]
  ];
  var food = [0, 3];
  var direction = 'up';
  late Timer timer;
  double speed = 0.75;
  var isPlaying = false;

  void startGame() {
    speed = 0.75;

    snake = [
      [(squaresPerRow / 2).floor(), (squaresPerCol / 2).floor()]
    ];
    snake.add([snake.first[0], snake.first[1] + 1]);
    snake.add([snake.first[0], snake.first[1] + 2]);
    createFood();

    isPlaying = true;
    Timer.periodic(Duration(milliseconds: 300 ~/ speed), (Timer timer) {
      moveSnake();
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case 'up':
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;
        case 'down':
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;
        case 'left':
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;
        case 'right':
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
      }

      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        speed = speed + 0.25;
        print(speed);
        createFood();
      }
    });
  }

  void createFood() {
    food = [
      randomGen.nextInt(squaresPerRow),
      randomGen.nextInt(squaresPerCol),
    ];
  }

  bool checkGameOver() {
    if (!isPlaying ||
        snake.first[1] < 0 ||
        snake.first[1] >= squaresPerCol ||
        snake.first[0] < 0 ||
        snake.first[0] > squaresPerRow) {
      return true;
    }

    for (var i = 1; i < snake.length; ++i) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }

    return false;
  }

  void endGame() {
    isPlaying = false;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over'),
            content: Text(
              'Score: ${snake.length - 2}',
              style: const TextStyle(fontSize: 20),
            ),
            actions: <Widget>[
              RawMaterialButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: squaresPerRow / (squaresPerCol + 2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: squaresPerRow,
                  ),
                  itemCount: squaresPerRow * squaresPerCol,
                  itemBuilder: (BuildContext context, int index) {
                    Color? color;
                    var x = index % squaresPerRow;
                    var y = (index / squaresPerRow).floor();

                    bool isSnakeBody = false;
                    for (var pos in snake) {
                      if (pos[0] == x && pos[1] == y) {
                        isSnakeBody = true;
                        break;
                      }
                    }

                    if (snake.first[0] == x && snake.first[1] == y) {
                      color = Colors.green;
                    } else if (isSnakeBody) {
                      color = Colors.green[200];
                    } else if (food[0] == x && food[1] == y) {
                      color = Colors.red;
                    } else {
                      color = Colors.grey[900];
                    }

                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    shape: const CircleBorder(),
                    fillColor: Colors.orange,
                    onPressed: (() {
                      if (direction != 'down') {
                        direction = 'up';
                      }
                    }),
                    child: const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RawMaterialButton(
                    shape: const CircleBorder(),
                    fillColor: Colors.orange,
                    onPressed: (() {
                      if (direction != 'right') {
                        direction = 'left';
                      }
                    }),
                    child: const Icon(
                      Icons.keyboard_arrow_left,
                      color: Colors.black,
                    ),
                  ),
                  RawMaterialButton(
                    shape: const CircleBorder(),
                    fillColor: Colors.orange,
                    onPressed: (() {
                      if (direction != 'left') {
                        direction = 'right';
                      }
                    }),
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    shape: const CircleBorder(),
                    fillColor: Colors.orange,
                    onPressed: (() {
                      if (direction != 'up') {
                        direction = 'down';
                      }
                    }),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ]),
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RawMaterialButton(
                      fillColor: isPlaying ? Colors.red : Colors.orange,
                      child: Text(
                        isPlaying ? 'End' : 'Start',
                        style: fontStyle,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          isPlaying = false;
                        } else {
                          startGame();
                        }
                      }),
                  Text(
                    'Score: ${snake.length - 2}',
                    style: fontStyle,
                  ),
                ],
              )),
        ]),
      ),
    );
  }
}
