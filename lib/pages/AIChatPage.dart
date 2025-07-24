import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../functions/payment_service.dart';
import 'package:http/http.dart' as http;

// Re-using ChatUser and ChatMessage classes for consistency
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

class AIChatPage extends StatefulWidget {
  final Map<String, String>? initialAnswers;

  const AIChatPage({super.key, this.initialAnswers});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  bool _isProcessingPayment = false;
  bool _isAILoading = false;
  int tries = 0;
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Singaplorer AI");
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

  final TextEditingController _chatTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // New variable to store the last AI prompt
  String? _lastAIPrompt;

  @override
  void initState() {
    super.initState();
    _tokenFuture = aiTokenCheck();

    if (widget.initialAnswers != null && widget.initialAnswers!.isNotEmpty) {
      _answers.addAll(widget.initialAnswers!);
      _itineraryGenerated = true;
      _sendToGemini();
    } else {
      _askNextQuestion();
    }
  }

  @override
  void dispose() {
    _chatTextController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      _scrollToBottom();
    } else {
      _itineraryGenerated = true;
      _sendToGemini();
    }
  }

  void _sendMessage(ChatMessage chatMessage) async {
    if (_itineraryGenerated) {
      if (tries < 4) {
        tries++;
      } else {
        await consumeToken(1);
      }
    }
    // Show user message immediately
    setState(() {
      messages.insert(0, chatMessage);
    });
    _scrollToBottom();

    // Always attempt to update answers if possible, even before token check
    // This ensures _answers is up-to-date for prompt generation
    if (!_itineraryGenerated) {
      if (_questionIndex < _questions.length) {
        _answers[_questions[_questionIndex]] = chatMessage.text;
        _questionIndex++;
        Future.delayed(const Duration(milliseconds: 300), _askNextQuestion);
        return; // Exit if still in initial question phase
      }
    }

    // After initial questions, check tokens BEFORE attempting any AI interaction
    // This applies to both new prompts and _tryHandleParameterChange which leads to _sendGeminiMessage
    int currentTokens = await _tokenFuture;

    // Define the minimum tokens required for an AI interaction
    // If you want 0 free tries, set this to 1. If you want 3 free tries, set this to 1.
    // The 'tries' counter will then manage the free interactions.
    const int tokensRequiredForAI = 1; // Assuming 1 token per AI interaction

    if (currentTokens < tokensRequiredForAI) {
      // Store the prompt that was about to be sent before showing the dialog
      _lastAIPrompt = _composeFullPrompt(chatMessage.text);
      _showNoTokensDialog();
      return; // Stop further processing if insufficient tokens
    }

    // If tokens are sufficient, proceed with AI interaction or parameter change
    // Consume token here if you want to consume it for *every* AI interaction
    // regardless of 'tries' for basic interactions.
    // If you want 'tries' to grant free interactions before consumption, adjust this.

    // The 'tries' counter should manage free interactions before actual token consumption.
    // Let's modify the consumption logic.
    // if (_itineraryGenerated) {
    //   if (tries < 4) {
    //     tries++;
    //   } else {
    //     await consumeToken(1);
    //   }
    // }

    // If the user's message is a parameter change, update and regenerate.
    // This will internally call _sendGeminiMessage with the updated context.
    if (!_tryHandleParameterChange(chatMessage.text)) {
      // If it's not a parameter change, send the message to Gemini normally.
      // The token consumption for this interaction should have been handled above.
      _sendGeminiMessage(_composeFullPrompt(chatMessage.text));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

    // Iterate through answers to find a match and update
    for (int i = 0; i < _questions.length; i++) {
      final questionKey = _questions[i]
          .toLowerCase(); // Use lowercase for comparison
      if (lowerInput.contains(questionKey.split(' ')[0].toLowerCase())) {
        // Simple check for first word of question
        String? newValue;
        if (i == 1 || i == 2 || i == 3) {
          // People, Budget, Duration
          final number = extractNumber(userInput);
          if (number != null) {
            newValue = number.toString();
          }
        } else {
          // For category and goals, try to extract relevant words
          if (lowerInput.contains("adventure"))
            newValue = "Adventure";
          else if (lowerInput.contains("chill"))
            newValue = "Chill";
          else if (lowerInput.contains("fun"))
            newValue = "Fun";
          else if (lowerInput.contains("learn") ||
              lowerInput.contains("history") ||
              lowerInput.contains("culture"))
            newValue = "Learning/History/Culture";
          else
            newValue =
                userInput; // Fallback to full input if no specific keyword matched
        }

        if (newValue != null && newValue.isNotEmpty) {
          _answers[_questions[i]] =
              newValue; // Update using original question string
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
    _scrollToBottom();
  }

  void _sendToGemini() {
    setState(() {
      _isAILoading = true;
    });

    final prompt = _composeFullPrompt(
      null,
    ); // No specific user input for initial generation
    _lastAIPrompt = prompt; // Store the initial generation prompt
    _sendGeminiMessage(prompt);
  }

  String _composeFullPrompt(String? latestUserInput) {
    final StringBuffer prompt = StringBuffer();
    prompt.writeln(
      "You are Singaplorer AI, an expert travel assistant for Singapore.",
    );
    prompt.writeln(
      "Here are the user's current preferences for their trip to Singapore:",
    );

    _answers.forEach((question, answer) {
      prompt.writeln("* ${question.replaceAll('?', '')}: $answer");
    });

    if (latestUserInput != null) {
      prompt.writeln("\nThe user's latest message is: \"$latestUserInput\"");
      prompt.writeln(
        "Please adjust the itinerary or respond to their query based on this message and their overall preferences.",
      );
    } else {
      prompt.writeln(
        "\nPlease generate a personalized itinerary with daily activities, estimated costs, and recommendations based on these preferences.",
      );
      prompt.writeln(
        "Keep the response in a markdown format that is editable and easy to understand.",
      );
    }
    return prompt.toString();
  }

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
      if (response.statusCode == 200) {
        int userToken = (jsonDecode(response.body) as num).toInt();
        return userToken;
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendAIChatToServer(String aiMessage) async {
    final url = Uri.parse('http://10.0.2.2:3000/api/add/aichat');
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
    setState(() {
      _isAILoading = true;
    });

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
            final botReply = ChatMessage(
              user: geminiUser,
              text: fullResponse,
              createdAt: DateTime.now(),
              isInitialQuestion: false,
            );

            setState(() {
              _isAILoading = false;
              messages.insert(0, botReply);
            });
            _scrollToBottom();
          },
          onError: (e) {
            print("Gemini error: $e");
            setState(() {
              _isAILoading = false;
              messages.insert(
                0,
                ChatMessage(
                  user: geminiUser,
                  text:
                      "I apologize, but I encountered an error. Please try again.",
                  createdAt: DateTime.now(),
                  isInitialQuestion: false,
                ),
              );
            });
            _scrollToBottom();
          },
        );
  }

  void handlePayment() async {
    if (_isProcessingPayment) return;
    setState(() {
      _isProcessingPayment = true;
    });

    final result = await makePayment();

    if (!mounted) return;

    switch (result) {
      case PaymentResult.success:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment completed!')));
        final url = Uri.parse('http://10.0.2.2:3000/api/addAiToken');
        final response = await http.put(url);
        if (response.statusCode == 200) {
          setState(() {
            _tokenFuture =
                aiTokenCheck(); // Refresh token count after successful consumption
          });
          // After successful payment and token update, re-run the last AI operation
          if (_itineraryGenerated && _lastAIPrompt != null) {
            _addSystemMessage("Tokens added! Continuing with your request...");
            _sendGeminiMessage(_lastAIPrompt!);
            _lastAIPrompt = null; // Clear the last prompt after re-attempt
          } else if (!_itineraryGenerated) {
            // If we were in the initial question phase and ran out of tokens
            // for the AI's response, ask the next question.
            Future.delayed(const Duration(milliseconds: 300), _askNextQuestion);
          }
        }
        break;
      case PaymentResult.cancelled:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment was canceled.')));
        break;
      case PaymentResult.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
        break;
      case PaymentResult.unknownError:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
          ),
        );
        break;
    }
    if (mounted) {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  // Modified to accept amount to consume and send it in the request body
  Future<void> consumeToken(int amount) async {
    final url = Uri.parse('http://10.0.2.2:3000/api/consumeAiToken');
    final body = jsonEncode({"amount": amount}); // Send amount in body

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        }, // Crucial: Set content type
        body: body, // Send the JSON body
      );
      if (response.statusCode == 200) {
        print("Tokens consumed successfully: $amount");
        setState(() {
          _tokenFuture =
              aiTokenCheck(); // Refresh token count after successful consumption
        });
      } else {
        print(
          "Failed to consume tokens. Status: ${response.statusCode}, Body: ${response.body}",
        );
        // Consider more robust error handling / user feedback here
      }
    } catch (e) {
      print("Error consuming tokens: $e");
      // Consider more robust error handling / user feedback here
    }
  }

  void _showNoTokensDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No AI Tokens Left'),
          content: const Text(
            'You have no AI tokens remaining. Please top up to continue chatting with Singaplorer AI.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                handlePayment(); // Trigger the payment process
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA0000),
              ),
              child: const Text('Buy Tokens'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isAI = message.user.id == geminiUser.id;

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: isAI
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI's profile picture on the left
          if (isAI)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset('assets/images/mascot.png', height: 30),
              ),
            ),

          // Message Bubble (flexible to take available space)
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAI ? Colors.red.shade50 : Colors.red.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isAI ? 0 : 12),
                  topRight: Radius.circular(isAI ? 12 : 0),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: isAI
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  isAI ? MarkdownBody(data: message.text) : Text(message.text),
                  if (isAI &&
                      _itineraryGenerated &&
                      !message
                          .isInitialQuestion) // Only show for AI responses after initial questions
                    FutureBuilder<int>(
                      future: _tokenFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 20,
                          );
                        } else {
                          final tokenCount = snapshot.data ?? 0;

                          if (message.isFavorite) {
                            return const Icon(
                              Icons.bookmark,
                              color: Color.fromARGB(255, 255, 196, 0),
                              size: 20,
                            );
                          } else if (tokenCount >= 3) {
                            // Allow saving if 3 or more tokens
                            return IconButton(
                              icon: const Icon(
                                Icons.bookmark_border,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () async {
                                bool? confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Confirm saving message?',
                                      ),
                                      content: const Text(
                                        'Do you want to save this itinerary? This will consume 3 AI tokens.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFAA0000,
                                            ),
                                          ),
                                          child: const Text('Confirm'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed == true) {
                                  setState(() {
                                    message.isFavorite = true;
                                  });
                                  sendAIChatToServer(message.text);
                                  consumeToken(3);
                                }
                              },
                              padding: const EdgeInsets.only(top: 4),
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                            );
                          } else {
                            // If less than 3 tokens, show add_card icon
                            return IconButton(
                              icon: const Icon(
                                Icons.add_card,
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: _isProcessingPayment
                                  ? null
                                  : handlePayment,
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
            ),
          ),

          // User's profile picture on the right
          if (!isAI)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset('assets/images/mascot.png', height: 30),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Singaplorer is thinking...",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFAA0000),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: messages.length + (_isAILoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isAILoading && index == 0) {
                return _buildThinkingIndicator();
              }
              final messageIndex = _isAILoading ? index - 1 : index;
              return _buildMessage(messages[messageIndex]);
            },
          ),
        ),
        _buildInputBar(),
      ],
    );
  }

  // New widget for the circular token display
  Widget _buildTokenCircle(int tokenCount) {
    return Container(
      width: 40, // Adjust size as needed
      height: 40, // Adjust size as needed
      decoration: const BoxDecoration(
        color: Color(0xFFAA0000), // Red background
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars, // Using a star icon as a token emoji
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$tokenCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Token Count Display
          FutureBuilder<int>(
            future: _tokenFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12.0, right: 8.0),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFAA0000),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12.0, right: 8.0),
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 40,
                  ), // Increased size for visibility
                );
              } else {
                final tokenCount = snapshot.data ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                    right: 8.0,
                  ), // Adjusted padding
                  child: _buildTokenCircle(
                    tokenCount,
                  ), // Use the new token circle widget
                );
              }
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _chatTextController,
                        decoration: const InputDecoration(
                          hintText: "Type here...",
                          hintStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (text) {
                          if (text.trim().isEmpty) return;
                          final msg = ChatMessage(
                            user: currentUser,
                            text: text.trim(),
                            createdAt: DateTime.now(),
                          );
                          _chatTextController.clear();
                          _sendMessage(msg);
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFAA0000)),
                    onPressed: () {
                      final text = _chatTextController.text.trim();
                      if (text.isEmpty) return;
                      final msg = ChatMessage(
                        user: currentUser,
                        text: text,
                        createdAt: DateTime.now(),
                      );
                      _chatTextController.clear();
                      _sendMessage(msg);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Ask Singaplorer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFAA0000),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFAA0000),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: _buildUI(),
          ),
        ),
      ),
    );
  }
}
