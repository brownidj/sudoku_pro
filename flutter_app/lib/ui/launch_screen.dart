import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/sudoku_screen.dart';

class LaunchScreen extends StatefulWidget {
  final SudokuController controller;

  const LaunchScreen({super.key, required this.controller});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    widget.controller.ready.then((_) {
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    });
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SudokuScreen(controller: widget.controller),
      ),
    );
  }

  Future<void> _openGame({required bool startNewGame}) async {
    if (!_ready) {
      await widget.controller.ready;
    }
    if (!mounted) {
      return;
    }
    if (startNewGame) {
      widget.controller.onNewGame();
    }
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ZuDoKu 0.4.4',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "It's harder than you think: engage more parts of your brain and have twice the fun!",
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.asset(
                      'assets/images/icons/super_granny.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The Angry Grannies Dev Team',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'dev - DayDay',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'dev - SudokuQueen',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'tech advisor - Icy',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!widget.controller.hadSavedSessionAtLaunch)
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _openGame(startNewGame: false),
                      child: const Text('Play'),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => _openGame(startNewGame: false),
                          child: const Text('Resume'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => _openGame(startNewGame: true),
                          child: const Text('New game'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
