import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'main.dart';

const int nameCharLimit = 20;

bool trollModeEnabled = false;

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

      //clamping max imposters
      final maxImposters = names.length - 2;
      if (imposterCount > maxImposters) {
        imposterCount = maxImposters < 1 ? 1 : maxImposters;
      }
    });
  }

  Future<void> _startGame() async {
    if (names.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least 3 players to start!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      //await because it takes a moment to load
      final wordList = await loadWordList();

      if (!mounted) return;

      Navigator.push(
        context,
        _buildRoute(
          //where the game data from the player selection gets pushed
          GameScreen(
            playerNames: names,
            wordList: wordList,
            imposterCount: imposterCount,
            trollModeEnabled: trollModeEnabled,
          ),
        ),
      );
    } finally {
      //always runs so button never loads forever
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
            //add players box
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: nameCharLimit,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Player name',
                      labelStyle: TextStyle(color: mutedGrey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: mutedGrey,
                        ), // border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: accentRed,
                        ), // border when tapped/focused
                      ),
                    ),
                    onSubmitted: (_) => _addName(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addName, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),

            //player list
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
                    color: surfaceWhite,
                    child: ListTile(
                      title: Text(
                        names[index],
                        style: const TextStyle(color: bgCharcoal),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: accentRed),
                        onPressed: () => _removeName(index),
                      ),
                    ),
                  );
                },
              ),
            ),

            //imposter number selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Imposters:',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: imposterCount > 1
                      ? () => setState(() => imposterCount--)
                      : null,
                ),
                Text(
                  '$imposterCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: imposterCount < names.length - 2
                      ? () => setState(() => imposterCount++)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 8),

            //troll mode switch
            SwitchListTile(
              title: const Text(
                'Troll Mode',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Rare chance no one is the imposter',
                style: TextStyle(color: mutedGrey),
              ),
              value: trollModeEnabled,
              activeThumbColor: accentRed,
              activeTrackColor: accentRed.withValues(alpha: 0.4),
              inactiveThumbColor: mutedGrey,
              inactiveTrackColor: bgCharcoal.withValues(alpha: 0.4),
              onChanged: (value) => setState(() => trollModeEnabled = value),
            ),

            //start game button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startGame,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Start Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route _buildRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
