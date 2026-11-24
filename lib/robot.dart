
import 'dart:math';

class Robot {
  final String name;
  int energy;
  int lasers;

  Robot({
    required this.name,
    required this.energy,
    required this.lasers,
  });

  void attack(Robot enemy) {
    if (lasers <= 0 || enemy.energy <= 0) return;

    lasers--;
    final damage = Random().nextInt(15) + 10;
    enemy.energy = max(0, enemy.energy - damage);
  }

  void recharge() {
    energy = 100;
    lasers = 10;
  }
}
