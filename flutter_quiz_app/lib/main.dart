import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:collection/collection.dart';

void main() {
  runApp(MaterialApp(
    home: QuizApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _remainingTime = 60;
  late Timer _timer;
  List<int> _selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  Future<void> _loadQuestions() async {
    String data = await rootBundle.loadString('assets/questions.json');
    setState(() {
      _questions = json.decode(data)..shuffle(); // Shuffle questions
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          _showScore();
        }
      });
    });
  }

  void _answerQuestion() {
    if (ListEquality().equals(_selectedAnswers, _questions[_currentIndex]['correct'])) {
      _score++;
    }
    setState(() {
      _selectedAnswers.clear();
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        _timer.cancel();
        Future.delayed(Duration(milliseconds: 100), () => _showScore());
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedAnswers.contains(index)) {
        _selectedAnswers.remove(index);
      } else {
        _selectedAnswers.add(index);
      }
    });
  }

  void _showScore() {
    if (!mounted) return;

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ScoreScreen(score: _score, total: _questions.length),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        actions: [Text('Time: $_remainingTime s')],
      ),
      body: QuestionScreen(
        questionData: _questions[_currentIndex],
        onAnswerSelected: _toggleSelection,
        onSubmit: _answerQuestion,
        selectedAnswers: _selectedAnswers,
      ),
    );
  }
}

class QuestionScreen extends StatelessWidget {
  final dynamic questionData;
  final Function(int) onAnswerSelected;
  final Function() onSubmit;
  final List<int> selectedAnswers;

  QuestionScreen({required this.questionData, required this.onAnswerSelected, required this.onSubmit, required this.selectedAnswers});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          questionData['question'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...List.generate(
          questionData['options'].length,
              (index) => CheckboxListTile(
            title: Text(questionData['options'][index]),
            value: selectedAnswers.contains(index),
            onChanged: (bool? value) {
              onAnswerSelected(index);
            },
          ),
        ),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text('Submit Answer'),
        ),
      ],
    );
  }
}

class ScoreScreen extends StatelessWidget {
  final int score;
  final int total;
  ScoreScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: $score / $total', style: TextStyle(fontSize: 22)),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => QuizApp()),
              ),
              child: Text('Restart Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
