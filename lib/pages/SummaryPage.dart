import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  late Future<List<String>> _futureAiMessages;

  @override
  void initState() {
    super.initState();
    _futureAiMessages = fetchAiMessages();
  }

  Future<List<String>> fetchAiMessages() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/aichat'),
      headers: {
        'Authorization': 'Bearer your_token_here', // if you need auth
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Extract the aiMessage field from each item
      return data.map<String>((item) => item['aiMessage'] as String).toList();
    } else {
      throw Exception('Failed to fetch AI chat messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat Messages')),
      body: FutureBuilder<List<String>>(
        future: _futureAiMessages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages found.'));
          }

          final messages = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final markdownText = messages[index];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MarkdownBody(
                    data: markdownText,
                    styleSheet: MarkdownStyleSheet(
                      h2: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                      p: const TextStyle(fontSize: 16, height: 1.4),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      listBullet: const TextStyle(color: Colors.redAccent),
                      code: const TextStyle(
                        backgroundColor: Color(0xFFF5F5F5),
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
