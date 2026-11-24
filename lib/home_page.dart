import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'robot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late Robot red1;
  late Robot yellow2;

  String winnerText = 'Who will win?';

  bool showLotties = false;
  bool showStaticImages = true;
  bool fireRed1 = false;
  bool fireRed2 = false;
  bool fireYellow1 = false;
  bool fireYellow2 = false;
  bool lotty2dVisible = false;
  bool isGameStarted = false;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    setRandomValues();
    _audioPlayer.setVolume(1.0);
  }

  void setRandomValues() {
    final random = Random();
    red1 = Robot(
      name: 'OPTIMUS',
      energy: random.nextInt(7000) + 100,
      lasers: random.nextInt(50) + 1,
    );
    yellow2 = Robot(
      name: 'Galactus',
      energy: random.nextInt(7000) + 100,
      lasers: random.nextInt(50) + 1,
    );
    winnerText = 'Who will win?';
    isGameOver = false;
  }

  Future<void> _playSound(int type) async {
    String fileName;
    if (type == 1) {
      fileName = 'attack_laser.mp3';
    } else if (type == 2) {
      fileName = 'laser_shot.mp3';
    } else {
      fileName = 'explosion_yellow.mp3';
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  bool _checkGaming() {
    if (red1.energy <= 0 || yellow2.energy <= 0) {
      _stopping();
      return false;
    }
    return true;
  }

  void _stopping() {
    if (isGameOver) return;
    setState(() {
      isGameOver = true;
      winnerText = red1.energy <= 0 ? 'Galactus won!' : 'Optimus won!';
      showLotties = false;
    });
    _playSound(3);
  }

  void _onFight(int type) {
    if (!_checkGaming() || !isGameStarted) return;

    _playSound(type == 1 || type == 3 ? 1 : 2);

    setState(() {
      if (type == 1) {
        fireRed1 = true;
        yellow2.energy = max(0, yellow2.energy - red1.lasers);
        red1.energy = max(0, red1.energy - 200);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => fireRed1 = false);
        });
      } else if (type == 2) {
        fireRed2 = true;
        yellow2.energy = max(0, yellow2.energy - 200);
        red1.energy = max(0, red1.energy - red1.lasers);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => fireRed2 = false);
        });
      } else if (type == 3) {
        fireYellow1 = true;
        red1.energy = max(0, red1.energy - 200);
        yellow2.energy = max(0, yellow2.energy - yellow2.lasers);
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) setState(() => fireYellow1 = false);
        });
      } else if (type == 4) {
        fireYellow2 = true;
        red1.energy = max(0, red1.energy - 200);
        yellow2.energy = max(0, yellow2.energy - yellow2.lasers);
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) setState(() => fireYellow2 = false);
        });
      }
    });

    _checkGaming();
  }

  void _startGame() {
    setState(() {
      isGameStarted = true;
      isGameOver = false;
      showStaticImages = false;
      showLotties = true;
      lotty2dVisible = true;
    });
  }

  void _restartGame() {
    setState(() {
      setRandomValues();
      isGameStarted = true;
      isGameOver = false;
      showStaticImages = false;
      showLotties = true;
      lotty2dVisible = true;
      fireRed1 = false;
      fireRed2 = false;
      fireYellow1 = false;
      fireYellow2 = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildStatsRow(
      String firstLabel,
      String firstValue,
      String secondLabel,
      String secondValue,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '$firstLabel $firstValue',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '$secondLabel $secondValue',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fightBtn(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 145,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0f4c81),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isGameOver ? null : onPressed,
        child: Text(label),
      ),
    );
  }

  Widget _robotName(String name, Color color) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          name,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _energyBar(int energy, Color color) {
    final value = (energy / 7100).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 15,
        backgroundColor: const Color(0xff1b2f4d),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _robotImages() {
    return SizedBox(
      height: 245,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showLotties) ...[
            Positioned(
              left: -38,
              top: -50,
              child: Lottie.asset(
                'assets/lottie/red_robot.json',
                width: 230,
                height: 230,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) =>
                const SizedBox.shrink(),
              ),
            ),
            if (lotty2dVisible)
              Positioned(
                right: -20,
                top: 55,
                child: Lottie.asset(
                  'assets/lottie/y_robot.json',
                  width: 178,
                  height: 180,
                  errorBuilder: (context, error, stack) =>
                  const SizedBox.shrink(),
                ),
              ),
          ],
          if (showStaticImages)
            Positioned.fill(
              top: 25,
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/red_robot100.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) =>
                      const Icon(Icons.smart_toy, size: 125,
                          color: Colors.redAccent),
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/img_yellow_robot100.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) =>
                      const Icon(Icons.smart_toy, size: 125,
                          color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          if (fireRed1)
            const Positioned(
              left: 40,
              top: 90,
              child: Icon(Icons.bolt, size: 90, color: Color(0xffff6b8a)),
            ),
          if (fireRed2)
            const Positioned(
              left: 40,
              top: 154,
              child: Icon(Icons.flash_on, size: 90, color: Color(0xffff9aae)),
            ),
          if (fireYellow1)
            const Positioned(
              right: 70,
              top: 86,
              child: Icon(Icons.bolt, size: 90, color: Color(0xff5ce1ff)),
            ),
          if (fireYellow2)
            const Positioned(
              right: 70,
              top: 150,
              child: Icon(Icons.flash_on, size: 90, color: Color(0xffbff4ff)),
            ),
        ],
      ),
    );
  }

  Widget _gamePanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff06142a).withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff5ce1ff).withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _robotName('OPTIMUS', const Color(0xff8fe9ff)),
              const SizedBox(width: 8),
              _robotName('GALACTUS', const Color(0xff8fe9ff)),
            ],
          ),
          const SizedBox(height: 8),
          _robotImages(),
          const SizedBox(height: 10),
          _buildStatsRow(
            'Energy1:',
            red1.energy.toString(),
            'Energy2:',
            yellow2.energy.toString(),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _energyBar(red1.energy, const Color(0xffff4d6d))),
              const SizedBox(width: 12),
              Expanded(child: _energyBar(yellow2.energy, const Color(0xff5ce1ff))),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatsRow(
            'Lasers1:',
            red1.lasers.toString(),
            'Lasers2:',
            yellow2.lasers.toString(),
          ),
          const SizedBox(height: 10),
          Text(
            winnerText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xffe6fbff),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (!isGameStarted)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0f4c81),
                minimumSize: const Size(150, 60),
              ),
              onPressed: _startGame,
              child: const Text(
                'Start',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          if (isGameStarted && !isGameOver) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _fightBtn('Fight Up!', () => _onFight(1)),
                _fightBtn('Fight Up!', () => _onFight(3)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _fightBtn('Fight Down!', () => _onFight(2)),
                _fightBtn('Fight Down!', () => _onFight(4)),
              ],
            ),
          ],
          if (isGameOver)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5ce1ff),
                  foregroundColor: const Color(0xff04121f),
                  minimumSize: const Size(240, 90),
                ),
                onPressed: _restartGame,
                child: const Text(
                  'Game Over\nStart Again',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, color: Color(0xff04121f), fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
return Scaffold(
body: Stack(
children: [
// Космический фон на весь экран
Positioned.fill(
child: Image.asset(
'assets/images/cosmos_compositing16.jpg',
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) {
debugPrint('Background error: $error');
return Container(
color: const Color(0xff050b1a),
);
},
),
),

// Затемнение поверх фона
Positioned.fill(
child: Container(
color: Colors.black.withOpacity(0.20),
),
),

// Игровое поле
SafeArea(
child: LayoutBuilder(
builder: (context, constraints) {
return SingleChildScrollView(
child: ConstrainedBox(
constraints: BoxConstraints(
minHeight: constraints.maxHeight,
),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 950,
),
child: Padding(
padding: const EdgeInsets.symmetric(
vertical: 18,
),
child: _gamePanel(),
                    ),
                    ),
                    ),
                  ),
                );
              },
              ),
              ),
              ],
              ),
              );
            }
          }