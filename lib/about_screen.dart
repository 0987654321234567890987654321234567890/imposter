import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Imposter App Feedback',
    );
    await launchUrl(uri);
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
              'A social deduction game. Find the imposter before they can figure out the word!',
              style: TextStyle(fontSize: 18, color: mutedGrey),
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
            const SizedBox(height: 32),
            //feedback & contact
            const Text(
              'Found an issue or have any feedback?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'I appreciate every bit of feedback!',
              style: TextStyle(fontSize: 18, color: mutedGrey),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _openEmail('cfield.ww@gmail.com'),
              icon: const Icon(Icons.email_outlined, color: accentRed),
              label: const Text(
                'cfield.ww@gmail.com',
                style: TextStyle(fontSize: 18, color: accentRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
