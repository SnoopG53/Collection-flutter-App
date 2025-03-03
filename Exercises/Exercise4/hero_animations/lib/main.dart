import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero Animation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Animation Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Standard Hero Animation
            _buildAnimationTile(
              context,
              'Standard Hero Animation',
              const StandardHeroPage(),
            ),
            // Radial Expansion Animation
            _buildAnimationTile(
              context,
              'Radial Expansion Animation',
              const RadialHeroPage(),
            ),
            // Fade Through Hero Animation
            _buildAnimationTile(
              context,
              'Fade-Through Hero Animation',
              const FadeThroughHeroPage(),
            ),
            // Scale Transition Hero Animation
            _buildAnimationTile(
              context,
              'Scale Hero Animation',
              const ScaleHeroPage(),
            ),
            // Slide Transition Hero Animation
            _buildAnimationTile(
              context,
              'Slide Hero Animation',
              const SlideHeroPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationTile(BuildContext context, String title, Widget page) {
    return Card(
      child: ListTile(
        title: Text(title),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ),
      ),
    );
  }
}

// ---------------- 1️⃣ Standard Hero Animation ----------------

class StandardHeroPage extends StatelessWidget {
  const StandardHeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standard Hero Animation')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HeroDetailPage()),
            );
          },
          child: Hero(
            tag: 'standardHero',
            child: Image.network(
              'https://flutter.dev/images/flutter-logo-sharing.png',
              width: 100,
            ),
          ),
        ),
      ),
    );
  }
}

class HeroDetailPage extends StatelessWidget {
  const HeroDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Hero(
          tag: 'standardHero',
          child: Image.network(
            'https://flutter.dev/images/flutter-logo-sharing.png',
            width: 300,
          ),
        ),
      ),
    );
  }
}

// ---------------- 2️⃣ Radial Expansion Hero Animation ----------------

class RadialHeroPage extends StatelessWidget {
  const RadialHeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radial Expansion Hero')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 700),
                pageBuilder: (_, __, ___) => const RadialDetailPage(),
              ),
            );
          },
          child: Hero(
            tag: 'radialHero',
            child: ClipOval(
              child: Image.network(
                'https://flutter.dev/images/flutter-logo-sharing.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RadialDetailPage extends StatelessWidget {
  const RadialDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: 'radialHero',
          child: ClipOval(
            child: Image.network(
              'https://flutter.dev/images/flutter-logo-sharing.png',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- 3️⃣ Fade-Through Hero Animation ----------------

class FadeThroughHeroPage extends StatelessWidget {
  const FadeThroughHeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fade-Through Hero Animation')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 700),
                pageBuilder: (_, animation, __) {
                  return FadeTransition(
                    opacity: animation,
                    child: const HeroDetailPage(),
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: 'fadeHero',
            child: Image.network(
              'https://flutter.dev/images/flutter-logo-sharing.png',
              width: 100,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- 4️⃣ Scale Transition Hero Animation ----------------

class ScaleHeroPage extends StatelessWidget {
  const ScaleHeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scale Hero Animation')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 700),
                pageBuilder: (_, animation, __) {
                  return ScaleTransition(
                    scale: animation,
                    child: const HeroDetailPage(),
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: 'scaleHero',
            child: Image.network(
              'https://flutter.dev/images/flutter-logo-sharing.png',
              width: 100,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- 5️⃣ Slide Transition Hero Animation ----------------

class SlideHeroPage extends StatelessWidget {
  const SlideHeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slide Hero Animation')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 700),
                pageBuilder: (_, animation, __) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: const HeroDetailPage(),
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: 'slideHero',
            child: Image.network(
              'https://flutter.dev/images/flutter-logo-sharing.png',
              width: 100,
            ),
          ),
        ),
      ),
    );
  }
}