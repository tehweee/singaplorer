import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class SummaryAiChatPage extends StatefulWidget {
  const SummaryAiChatPage({super.key});

  @override
  State<SummaryAiChatPage> createState() => _SummaryAiChatPageState();
}

class _SummaryAiChatPageState extends State<SummaryAiChatPage> {
  late Future<List<String>> _futureAiMessages;

  // Define the primary color based on the hex code #780000
  final Color _primaryRed = const Color(0xFF780000);

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
      appBar: AppBar(
        title: const Text(
          'AI Chat Messages',
          style: TextStyle(color: Colors.white), // White title for contrast
        ),
        backgroundColor: _primaryRed, // Use the deep red for the AppBar
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
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
            padding: const EdgeInsets.all(
              16,
            ), // Increased padding for a softer look
            itemCount: messages.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 16), // Spacing between cards
            itemBuilder: (context, index) {
              final markdownText = messages[index];

              return Card(
                elevation: 6, // Increased elevation for more depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ), // More rounded corners
                  side: BorderSide(
                    color: _primaryRed.withOpacity(0.3),
                    width: 1,
                  ), // Subtle border
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                ), // Add vertical margin for cards
                child: Padding(
                  padding: const EdgeInsets.all(
                    20,
                  ), // Increased padding inside card
                  child: MarkdownBody(
                    data: markdownText,
                    styleSheet: MarkdownStyleSheet(
                      // Customizing headers
                      h1: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _primaryRed, // Use primary red for H1
                      ),
                      h2: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primaryRed, // Use primary red for H2
                      ),
                      h3: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryRed.withOpacity(
                          0.8,
                        ), // Slightly lighter red for H3
                      ),
                      // Paragraph style
                      p: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ), // Increased line height, slightly softer text color
                      // Strong/bold text style
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Pure black for strong text
                      ),
                      // List bullet style
                      listBullet: TextStyle(
                        color: _primaryRed,
                        fontSize: 18,
                      ), // Larger, red bullets
                      // Code block style
                      code: const TextStyle(
                        backgroundColor: Color(
                          0xFFF0F0F0,
                        ), // Lighter grey background
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Colors.black87,
                        // REMOVED: borderRadius: BorderRadius.all(Radius.circular(4)), // This line caused the error
                      ),
                      // Link style
                      a: TextStyle(
                        color: _primaryRed,
                        decoration: TextDecoration.underline,
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
