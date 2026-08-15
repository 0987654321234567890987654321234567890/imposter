import 'package:flutter/material.dart';
import 'flip_card_screen.dart';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

Future<List<WordEntry>> loadWordList() async {
  final rawCsv = await rootBundle.loadString(
    'lib/assets/imposter_words_v2.csv',
  );
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

List<Player> generatePlayers(
  List<String> names,
  List<WordEntry> wordList,
  int imposterCount,
  bool trollModeEnabled,
) {
  final random = Random();
  final word = wordList[random.nextInt(wordList.length)];

  final isTrollRound = trollModeEnabled && random.nextInt(15) == 0;

  if (isTrollRound) {
    return List.generate(names.length, (i) {
      return Player(name: names[i], label: word.word, hint: '');
    });
  }

  final allIndices = List.generate(names.length, (i) => i)..shuffle(random);
  final imposterIndices = allIndices.take(imposterCount).toSet();

  return List.generate(names.length, (i) {
    return Player(
      name: names[i],
      label: imposterIndices.contains(i) ? 'IMPOSTER' : word.word,
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
  final int imposterCount;
  final bool trollModeEnabled;
  const GameScreen({
    super.key,
    required this.playerNames,
    required this.wordList,
    required this.imposterCount,
    required this.trollModeEnabled,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final List<Player> players = generatePlayers(
    widget.playerNames,
    widget.wordList,
    widget.imposterCount,
    widget.trollModeEnabled,
  );

  bool showingPlayerStart = false;

  int currentIndex = 0;
  int turnCount = 0;

  final random = Random();
  late int startingPlayer = random.nextInt(players.length);
  late String startingPlayerName = players[startingPlayer].name;

  void _nextPlayer() {
    setState(() {
      if ((turnCount + 1) % players.length == 0 && !showingPlayerStart) {
        showingPlayerStart = true;
      } else {
        currentIndex = (currentIndex + 1) % players.length;
        turnCount++;
        showingPlayerStart = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = players[currentIndex];
    final currentColor = cardColors[turnCount % cardColors.length];

    String buttonText = "Next Player";
    if (showingPlayerStart) buttonText = "Revisit Words";

    return Scaffold(
      appBar: AppBar(title: const Text('Imposter Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!showingPlayerStart)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300,
                    height: 100,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 300,
                        child: Text(
                          '${current.name}\'s turn',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FlipCard(
                    key: ValueKey(currentIndex),
                    label: current.label,
                    hint: current.hint,
                    color: currentColor,
                  ),
                  const SizedBox(height: 24),
                ],
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300,
                    height: 400,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 300,
                        child: Text(
                          '$startingPlayerName starts the conversation!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ElevatedButton(
              onPressed: _nextPlayer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(buttonText, style: TextStyle(fontSize: 30)),
            ),
          ],
        ),
      ),
    );
  }
}
