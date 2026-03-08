import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/launch_screen.dart';

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  late final SudokuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SudokuController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZuDoKu Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: LaunchScreen(controller: _controller),
    );
  }
}
