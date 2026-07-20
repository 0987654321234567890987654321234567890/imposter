import 'package:flutter/material.dart';
import 'flip_card_screen.dart';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

Future<List<WordEntry>> loadWordList() async {
  final rawCsv = await rootBundle.loadString('lib/assets/words.csv');
  final rows = csv.decode(rawCsv);

  return rows.map((row) {
    final word = row[0].toString();
    final hints = row
        .skip(1)
        .map((h) => h.toString())
        .where((h) => h.trim().isNotEmpty)
        .toList();

    return WordEntry(word: word, hints: hints);
  }).toList();
}

final Color pink = Color.fromRGBO(255, 17, 196, 1);
final Color teal = Color.fromARGB(255, 0, 184, 184);

class WordEntry {
  final String word;
  final List<String> hints;

  const WordEntry({required this.word, required this.hints});
}

final List<Color> cardColors = [
  Colors.yellow,
  Colors.blue,
  Colors.orange,
  Colors.green,
  pink,
  teal,
];

List<Player> generatePlayers(List<String> names, List<WordEntry> wordList) {
  final random = Random();
  final word = wordList[random.nextInt(wordList.length)];
  final imposterIndex = random.nextInt(names.length);

  return List.generate(names.length, (i) {
    return Player(
      name: names[i],
      label: i == imposterIndex ? 'IMPOSTER' : word.word,
      hint: word.hints[random.nextInt(word.hints.length)],
    );
  });
}

class Player {
  final String name;
  final String label;
  final String hint;

  const Player({required this.name, required this.label, required this.hint});
}

class GameScreen extends StatefulWidget {
  final List<String> playerNames;
  final List<WordEntry> wordList;
  const GameScreen({
    super.key,
    required this.playerNames,
    required this.wordList,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final List<Player> players = generatePlayers(
    widget.playerNames,
    widget.wordList,
  );

  int currentIndex = 0;
  int turnCount = 0;

  void _nextPlayer() {
    setState(() {
      currentIndex = (currentIndex + 1) % players.length;
      turnCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = players[currentIndex];
    final currentColor = cardColors[turnCount % cardColors.length];

    return Scaffold(
      appBar: AppBar(title: const Text('Imposter Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${current.name}\'s turn',
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 24),
            FlipCard(
              key: ValueKey(currentIndex),
              label: current.label,
              hint: current.hint,
              color: currentColor,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextPlayer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Next Player', style: TextStyle(fontSize: 30)),
            ),
          ],
        ),
      ),
    );
  }
}
