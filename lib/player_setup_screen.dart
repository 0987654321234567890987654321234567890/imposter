import 'package:flutter/material.dart';
import 'game_screen.dart';

const int nameCharLimit = 20;

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> names = [];
  final List<Key> _keys = [];
  bool _isLoading = false;
  int imposterCount = 1;

  void _addName() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    if (name.length > nameCharLimit) return;

    setState(() {
      names.add(name);
      _keys.add(UniqueKey());
      _controller.clear();
    });
  }

  void _removeName(int index) {
    setState(() {
      names.removeAt(index);
      _keys.removeAt(index);
    });
  }

  Future<void> _startGame() async {
    if (names.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 3 players to start!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final wordList = await loadWordList();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            playerNames: names,
            wordList: wordList,
            imposterCount: imposterCount,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Players')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // input row: text field + add button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: nameCharLimit,
                    decoration: const InputDecoration(
                      labelText: 'Player name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addName(), // lets them hit enter/done
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addName, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),

            // list of added players
            Expanded(
              child: ReorderableListView.builder(
                itemCount: names.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final name = names.removeAt(oldIndex);
                    names.insert(newIndex, name);
                    final key = _keys.removeAt(oldIndex);
                    _keys.insert(newIndex, key);
                  });
                },
                itemBuilder: (context, index) {
                  return Card(
                    key: _keys[index],
                    child: ListTile(
                      title: Text(names[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeName(index),
                      ),
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Imposters:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: imposterCount > 1
                      ? () => setState(() => imposterCount--)
                      : null,
                ),
                Text(
                  '$imposterCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: imposterCount < names.length - 2
                      ? () => setState(() => imposterCount++)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start Game', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
