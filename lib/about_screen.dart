import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //'about' text
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //imposter title
          children: [
            const Text(
              'Imposter',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            //game description
            const Text(
              'A social deduction game - find the imposter before they can figure out the word!',
              style: TextStyle(fontSize: 16, color: mutedGrey),
            ),
            const SizedBox(height: 32),
            //ko-fi link for donations
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openLink('https://ko-fi.com/cfield'),
                icon: const Icon(Icons.favorite, size: 20),
                label: const Text('Support this project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
