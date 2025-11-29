import 'package:flutter/material.dart';
import 'path_editor_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FRC Pathing Tool'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PathEditorPage(),
                  ),
                );
              },
              child: const Text('New Autonomous'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Load Autonomous (later)
              },
              child: const Text('Load Autonomous'),
            ),
          ],
        ),
      ),
    );
  }
}
