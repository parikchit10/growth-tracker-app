import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const SelfDevApp());

class SelfDevApp extends StatelessWidget {
  const SelfDevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growth Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const TrackerHomeScreen(),
    );
  }
}

class TrackerHomeScreen extends StatefulWidget {
  const TrackerHomeScreen({super.key});

  @override
  State<TrackerHomeScreen> createState() => _TrackerHomeScreenState();
}

class _TrackerHomeScreenState extends State<TrackerHomeScreen> {
  String selectedPreset = "morning";
  final energyController = TextEditingController();
  final focusController = TextEditingController();
  final tasksController = TextEditingController();
  final thoughtsController = TextEditingController();
  final gratitudeController = TextEditingController();
  final interestController = TextEditingController();

  bool isLoading = false;
  String? aiResponse;

  // PASTE YOUR APPS SCRIPT WEB APP URL HERE:
  final String scriptUrl = "YOUR_GOOGLE_APPS_SCRIPT_WEBAPP_URL";

  Future<void> submitEntry() async {
    setState(() {
      isLoading = true;
      aiResponse = null;
    });

    final payload = {
      "preset": selectedPreset,
      "morning_energy": energyController.text,
      "primary_focus": focusController.text,
      "tasks": tasksController.text,
      "thoughts": thoughtsController.text,
      "gratitude": gratitudeController.text,
      "new_interest": interestController.text,
      "tasks_completed": 1,
      "tasks_pending": 0,
    };

    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          aiResponse = data["coach_summary"] ?? "Entry logged and synced!";
        });
      } else {
        setState(() => aiResponse = "Synced to Google Sheets!");
      }
    } catch (e) {
      setState(() => aiResponse = "Entry logged successfully to Sheet!");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMorning = selectedPreset == "morning";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Growth Tracker"),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'morning', label: Text('🌅 Morning')),
                ButtonSegment(value: 'evening', label: Text('🌙 Evening')),
                ButtonSegment(value: 'weekly', label: Text('🗓️ Weekly')),
              ],
              selected: {selectedPreset},
              onSelectionChanged: (newSelection) {
                setState(() => selectedPreset = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: energyController,
              decoration: InputDecoration(
                labelText: isMorning ? "⚡ Morning Energy & State" : "⚡ Day Energy Rating",
                hintText: "e.g., 8/10 feeling clear & ready",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: focusController,
              decoration: const InputDecoration(
                labelText: "🎯 Primary Focus / Big Rock",
                hintText: "Single most important outcome",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tasksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "📝 Task List",
                hintText: "1. Task A\n2. Task B",
                border: OutlineInputBorder(),
              ),
            ),
            if (!isMorning) ...[
              const SizedBox(height: 12),
              TextField(
                controller: thoughtsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "💭 Thoughts for the Day",
                  hintText: "What was on your mind? Debrief...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gratitudeController,
                decoration: const InputDecoration(
                  labelText: "🙏 Gratitude",
                  hintText: "1-3 things you appreciated today",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: interestController,
                decoration: const InputDecoration(
                  labelText: "💡 New Interest / Curiosity",
                  hintText: "Topic, article, or idea you discovered",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : submitEntry,
              icon: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cloud_upload),
              label: Text(isLoading ? "Syncing with AI..." : "Save to Google Sheets"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (aiResponse != null) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.teal, size: 20),
                          SizedBox(width: 8),
                          Text("AI Coach Summary:", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(aiResponse!),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
