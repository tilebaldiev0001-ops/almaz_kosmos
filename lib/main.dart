
import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const KosmosHeroesApp());
}

class KosmosHeroesApp extends StatelessWidget {
  const KosmosHeroesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kosmos Almaz',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff5ce1ff),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}
