import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../functions/payment_service.dart';
import 'package:http/http.dart' as http;

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini");
  late Future<int> _tokenFuture;

  int _questionIndex = 0;
  final List<String> _questions = [
    "Which category would you like to choose? (Adventure, Chill, Fun)",
    "How many people will be travelling?",
    "What is your budget? (per person)",
    "How long do you want to go for the trip? (in days)",
    "Is there anything you'd like to learn or get from Singapore?",
  ];

  final Map<String, String> _answers = {};
  bool _itineraryGenerated = false;

  @override
  void initState() {
    super.initState();
    _askNextQuestion();
    _tokenFuture = aiTokenCheck();
  }

  void _askNextQuestion() {
    if (_questionIndex < _questions.length) {
      final question = _questions[_questionIndex];
      final msg = ChatMessage(
        user: geminiUser,
        text: question,
        createdAt: DateTime.now(),
        isInitialQuestion: true,
      );
      setState(() {
        messages.insert(0, msg);
      });
    } else {
      _itineraryGenerated = true;
      _sendToGemini();
    }
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages.insert(0, chatMessage);
    });

    if (!_itineraryGenerated) {
      if (_questionIndex < _questions.length) {
        _answers[_questions[_questionIndex]] = chatMessage.text;
        _questionIndex++;
        Future.delayed(const Duration(milliseconds: 300), _askNextQuestion);
      } else {
        _itineraryGenerated = true;
        _sendToGemini();
      }
    } else {
      if (!_tryHandleParameterChange(chatMessage.text)) {
        _sendGeminiMessage(_composeFollowUpPrompt(chatMessage.text));
      }
    }
  }

  bool _tryHandleParameterChange(String userInput) {
    final lowerInput = userInput.toLowerCase();

    final Map<String, String> paramKeys = {
      "category": _questions[0],
      "people": _questions[1],
      "budget": _questions[2],
      "duration": _questions[3],
      "days": _questions[3],
      "long": _questions[3],
      "goal": _questions[4],
      "goals": _questions[4],
    };

    bool updated = false;

    int? extractNumber(String input) {
      final match = RegExp(r'\d+').firstMatch(input);
      if (match != null) {
        return int.tryParse(match.group(0)!);
      }
      return null;
    }

    for (final entry in paramKeys.entries) {
      if (lowerInput.contains(entry.key)) {
        final key = entry.value;
        String? newValue;

        if (key == _questions[1] ||
            key == _questions[2] ||
            key == _questions[3]) {
          final number = extractNumber(userInput);
          if (number != null) {
            newValue = number.toString();
          }
        } else {
          newValue = userInput;
        }

        if (newValue != null && newValue.isNotEmpty) {
          _answers[key] = newValue;
          updated = true;
          break;
        }
      }
    }

    if (updated) {
      _addSystemMessage("Updated your preferences. Regenerating itinerary...");
      _sendToGemini();
    }

    return updated;
  }

  void _addSystemMessage(String text) {
    final msg = ChatMessage(
      user: geminiUser,
      text: text,
      createdAt: DateTime.now(),
      isInitialQuestion: false,
    );
    setState(() {
      messages.insert(0, msg);
    });
  }

  void _sendToGemini() {
    final summary =
        '''
I am planning a trip and here are my preferences:

*Category:* ${_answers[_questions[0]]}
*People:* ${_answers[_questions[1]]}
*Budget:* ${_answers[_questions[2]]}
*Duration:* ${_answers[_questions[3]]}
*Goals:* ${_answers[_questions[4]]}

Based on this, please generate a personalized itinerary with daily activities, estimated costs, and recommendations. Keep it editable so I can adjust later.
''';

    _sendGeminiMessage(summary);
  }

  String _composeFollowUpPrompt(String userInput) {
    return '''
User has these preferences:
Category: ${_answers[_questions[0]]}
People: ${_answers[_questions[1]]}
Budget: ${_answers[_questions[2]]}
Duration: ${_answers[_questions[3]]}
Goals: ${_answers[_questions[4]]}

User says: "$userInput"

Please update or respond accordingly.
''';
  }

  // Generate random 10-length userID
  String generateRandomUserId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(
      length,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  Future<int> aiTokenCheck() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/aiToken');
    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        int userToken = (jsonDecode(response.body) as num).toInt();
        return userToken;
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in aiTokenCheck: $e');
      rethrow;
    }
  }

  // Send the AI chat response to your Node.js API
  Future<void> sendAIChatToServer(String aiMessage) async {
    final userId = generateRandomUserId(10);
    final url = Uri.parse(
      'http://10.0.2.2:3000/api/add/aichat',
    ); // Replace with your API URL

    final body = jsonEncode({"aiMessage": aiMessage});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print("Success sending AI chat: ${response.body}");
      } else {
        print(
          "Failed to send AI chat. Status: ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      print("Error sending AI chat to server: $e");
    }
  }

  void _sendGeminiMessage(String userInput) {
    String buffer = "";

    gemini
        .promptStream(parts: [Part.text(userInput)])
        .listen(
          (event) {
            final chunk =
                event?.content?.parts?.fold(
                  '',
                  (prev, part) => part is TextPart ? "$prev${part.text}" : prev,
                ) ??
                '';
            buffer += chunk;
          },
          onDone: () async {
            final fullResponse = buffer.trim();

            debugPrint(
              "Gemini full response:\n${fullResponse.replaceAll('\n', ' ')}",
            );

            // Send the full response to Node.js API
            // await sendAIChatToServer(fullResponse);

            final botReply = ChatMessage(
              user: geminiUser,
              text: fullResponse,
              createdAt: DateTime.now(),
              isInitialQuestion: false,
            );

            setState(() {
              messages.insert(0, botReply);
            });
          },
          onError: (e) {
            print("Gemini error: $e");
          },
        );
  }

  void handlePayment() async {
    final result = await makePayment();

    if (!mounted) return;

    switch (result) {
      case PaymentResult.success:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment completed!')));
        final url = Uri.parse('http://10.0.2.2:3000/api/addAiToken');
        final response = await http.put(url);
        if (response.statusCode == 200) {
          jsonDecode(response.body);
          setState(() {
            _tokenFuture = aiTokenCheck();
          });
        } else {
          jsonDecode(response.body);
        }
        break;
      case PaymentResult.cancelled:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment was canceled.')));
        break;
      case PaymentResult.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Please try again.')),
        );
        break;
      case PaymentResult.unknownError:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Please try again.')),
        );
        break;
    }
  }

  void consumeToken() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/consumeAiToken');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      jsonDecode(response.body);
      setState(() {
        _tokenFuture = aiTokenCheck();
      });
    } else {
      jsonDecode(response.body);
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final isAI = message.user.id == geminiUser.id;

    return Container(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAI ? Colors.grey[200] : Colors.blue[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: isAI
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          isAI ? MarkdownBody(data: message.text) : Text(message.text),
          if (isAI && !message.isInitialQuestion)
            FutureBuilder<int>(
              future: aiTokenCheck(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                } else if (snapshot.hasError) {
                  return Icon(Icons.error, color: Colors.red, size: 20);
                } else {
                  final tokenCount = snapshot.data ?? 0;

                  if (message.isFavorite) {
                    // Always show yellow star if already favorited
                    return Icon(
                      Icons.star,
                      color: const Color.fromARGB(255, 255, 196, 0),
                      size: 20,
                    );
                  } else if (tokenCount >= 3) {
                    // Show gray star (can favorite)
                    return IconButton(
                      icon: Icon(
                        Icons.star_border,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () async {
                        bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Confirm saving message?'),
                              content: Text(
                                'Do you want to save this itinerary?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          setState(() {
                            message.isFavorite = true;
                          });
                          print("Favorite toggled: ${message.isFavorite}");
                          sendAIChatToServer(message.text);
                          consumeToken();
                        }
                      },
                      padding: const EdgeInsets.only(top: 4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    );
                  } else {
                    // Not enough tokens and not favorited: show monetization icon
                    return IconButton(
                      icon: Icon(Icons.monetization_on, size: 20),
                      onPressed: handlePayment,
                      padding: const EdgeInsets.only(top: 4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessage(messages[index]);
            },
          ),
        ),
        const Divider(height: 1),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildInputBar() {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) {
                if (text.trim().isEmpty) return;
                final msg = ChatMessage(
                  user: currentUser,
                  text: text.trim(),
                  createdAt: DateTime.now(),
                );
                controller.clear();
                _sendMessage(msg);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              final msg = ChatMessage(
                user: currentUser,
                text: text,
                createdAt: DateTime.now(),
              );
              controller.clear();
              _sendMessage(msg);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Travel Chat")),
      body: _buildUI(),
    );
  }
}

class ChatUser {
  final String id;
  final String firstName;

  ChatUser({required this.id, required this.firstName});
}

class ChatMessage {
  final ChatUser user;
  final String text;
  final DateTime createdAt;
  bool isFavorite;
  final bool isInitialQuestion;

  ChatMessage({
    required this.user,
    required this.text,
    required this.createdAt,
    this.isFavorite = false,
    this.isInitialQuestion = false,
  });
}
