import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InkDinoGame extends StatefulWidget {
  const InkDinoGame({super.key});

  @override
  State<InkDinoGame> createState() => _InkDinoGameState();
}

class _InkDinoGameState extends State<InkDinoGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Game state
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _scoreCounter = 0;

  // Dino state
  double _dinoY = 0.0; // 0 is ground
  double _dinoVelocity = 0.0;
  final double _gravity = -0.6; // downward
  final double _jumpVelocity = 11.0;

  // Obstacles
  final List<double> _obstacles = []; // store X positions
  final double _obstacleSpeed = 5.0;

  // Screen bounds
  double _screenWidth = 800.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 99), // Infinite duration
    )..addListener(_update);
  }

  void _update() {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      _scoreCounter++;
      if (_scoreCounter % 5 == 0) _score++;

      // Update Dino
      _dinoY += _dinoVelocity;
      _dinoVelocity += _gravity;

      if (_dinoY <= 0) {
        _dinoY = 0;
        _dinoVelocity = 0;
      }

      // Update Obstacles
      for (int i = 0; i < _obstacles.length; i++) {
        _obstacles[i] -= _obstacleSpeed;
      }

      // Remove off-screen obstacles
      if (_obstacles.isNotEmpty && _obstacles.first < -50) {
        _obstacles.removeAt(0);
      }

      // Spawn new obstacles
      if (_obstacles.isEmpty || _obstacles.last < _screenWidth - 250) {
        if (math.Random().nextDouble() < 0.015) {
          // Random spawn chance
          _obstacles.add(_screenWidth + 50.0); // Start off-screen right
        }
      }

      // Collision detection
      // Dino bounding box
      const dinoLeft = 55.0;
      const dinoRight = 85.0;
      final dinoBottom = _dinoY;
      final dinoTop = _dinoY + 35.0;

      for (final obsX in _obstacles) {
        final obsLeft = obsX + 5.0;
        final obsRight = obsX + 15.0;
        const obsBottom = 0.0;
        const obsTop = 40.0;

        if (dinoRight > obsLeft && dinoLeft < obsRight) {
          if (dinoBottom < obsTop && dinoTop > obsBottom) {
            // Collision!
            _isGameOver = true;
            _isPlaying = false;
          }
        }
      }
    });
  }

  void _jump() {
    if (_isGameOver) {
      // Restart
      setState(() {
        _isGameOver = false;
        _score = 0;
        _scoreCounter = 0;
        _obstacles.clear();
        _dinoY = 0;
        _dinoVelocity = 0;
      });
      _isPlaying = true;
      _controller.forward(from: 0.0);
      return;
    }

    if (!_isPlaying) {
      _isPlaying = true;
      _controller.forward(from: 0.0);
    }

    if (_dinoY == 0) {
      // On ground
      _dinoVelocity = _jumpVelocity;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 0) {
          _screenWidth = constraints.maxWidth;
        }
        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event.logicalKey == LogicalKeyboardKey.space) {
              if (event is KeyDownEvent) {
                _jump();
              }
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _jump,
            child: Container(
              color: Colors.transparent, // transparent to let grid show
              width: double.infinity,
              height: double.infinity,
              child: ClipRect(
                child: CustomPaint(
                  painter: _InkStylePainter(
                    dinoY: _dinoY,
                    obstacles: _obstacles,
                    score: _score,
                    isGameOver: _isGameOver,
                    isPlaying: _isPlaying,
                    tick: _controller.lastElapsedDuration?.inMilliseconds ?? 0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InkStylePainter extends CustomPainter {
  final double dinoY;
  final List<double> obstacles;
  final int score;
  final bool isGameOver;
  final bool isPlaying;
  final int tick;

  _InkStylePainter({
    required this.dinoY,
    required this.obstacles,
    required this.score,
    required this.isGameOver,
    required this.isPlaying,
    required this.tick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Put the ground exactly at 65% of the total height
    final double groundY = size.height * 0.65;

    // Draw Ground (Ink stroke with some randomness)
    final Path groundPath = Path();
    groundPath.moveTo(0, groundY);
    final random = math.Random(42);
    double x = 0;
    while (x < size.width) {
      x += 20 + random.nextDouble() * 30;
      double yOffset = (random.nextDouble() - 0.5) * 4;
      groundPath.lineTo(x, groundY + yOffset);
    }
    canvas.drawPath(groundPath, paint);

    // Add some random dots under the ground to simulate ink splatter
    final spotRandom = math.Random(42);
    for (int i = 0; i < 20; i++) {
      double spotX = spotRandom.nextDouble() * size.width;
      double spotY = groundY + 5 + spotRandom.nextDouble() * 20;
      canvas.drawCircle(
        Offset(spotX, spotY),
        spotRandom.nextDouble() * 1.5,
        paint..style = PaintingStyle.fill,
      );
    }
    paint.style = PaintingStyle.stroke; // restore

    // Draw Score
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SCORE: $score',
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width - textPainter.width - 30, groundY - 100),
    );

    // Messages
    if (!isPlaying && !isGameOver) {
      _drawCenterText(canvas, size, 'TAP TO JUMP\n(Ink Dino)', groundY - 60);
    } else if (isGameOver) {
      _drawCenterText(canvas, size, 'GAME OVER\nTAP TO RESTART', groundY - 60);
    }

    // Draw Obstacles (Cacti)
    for (final obsX in obstacles) {
      _drawCactus(canvas, obsX, groundY, paint);
    }

    // Draw Dino
    _drawDino(canvas, 50, groundY - dinoY, paint);
  }

  void _drawCenterText(Canvas canvas, Size size, String text, double yOffset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          letterSpacing: 2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        yOffset - textPainter.height,
      ),
    );
  }

  void _drawCactus(Canvas canvas, double x, double groundY, Paint paint) {
    // Simple ink cactus
    final Path path = Path();
    // Main trunk
    path.moveTo(x + 10, groundY);
    path.lineTo(x + 10, groundY - 40);
    // Left arm
    path.moveTo(x + 10, groundY - 20);
    path.lineTo(x + 2, groundY - 20);
    path.lineTo(x + 2, groundY - 30);
    // Right arm
    path.moveTo(x + 10, groundY - 15);
    path.lineTo(x + 18, groundY - 15);
    path.lineTo(x + 18, groundY - 25);

    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(x + 10, groundY - 40),
      1.5,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke;
  }

  void _drawDino(Canvas canvas, double x, double y, Paint paint) {
    final Path path = Path();

    // Start at head
    path.moveTo(x + 20, y - 40);
    path.lineTo(x + 35, y - 40);
    path.lineTo(x + 35, y - 30);
    path.lineTo(x + 40, y - 30);
    path.lineTo(x + 40, y - 25);
    path.lineTo(x + 25, y - 25);
    path.lineTo(x + 25, y - 20);
    path.lineTo(x + 30, y - 20);
    path.lineTo(x + 30, y - 15);
    path.lineTo(x + 20, y - 15);
    path.lineTo(x + 20, y - 5);

    // Tail
    path.lineTo(x + 5, y - 5);
    path.lineTo(x, y - 20);
    path.lineTo(x + 10, y - 20);
    path.lineTo(x + 15, y - 35);
    path.close();

    // Leg 1 (animated based on tick if playing and on ground)
    bool leg1Up = false;
    bool leg2Up = false;
    if (isPlaying && dinoY == 0) {
      int phase = (tick ~/ 150) % 2;
      if (phase == 0) {
        leg1Up = true;
      } else {
        leg2Up = true;
      }
    }

    final Path legs = Path();
    // Leg 1
    legs.moveTo(x + 16, y - 5);
    if (leg1Up) {
      legs.lineTo(x + 16, y - 2);
      legs.lineTo(x + 20, y - 2);
    } else {
      legs.lineTo(x + 16, y);
      legs.lineTo(x + 21, y);
    }

    // Leg 2
    legs.moveTo(x + 10, y - 5);
    if (leg2Up) {
      legs.lineTo(x + 10, y - 2);
      legs.lineTo(x + 14, y - 2);
    } else {
      legs.lineTo(x + 10, y);
      legs.lineTo(x + 15, y);
    }

    // Fill with a dark gray to simulate thick ink
    Paint fillPaint = Paint()
      ..color = const Color(0xDD000000)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw outline for extra ink look
    canvas.drawPath(path, paint);
    canvas.drawPath(legs, paint);

    // Eye
    Paint eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x + 28, y - 35), 2.5, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _InkStylePainter oldDelegate) {
    return true;
  }
}
