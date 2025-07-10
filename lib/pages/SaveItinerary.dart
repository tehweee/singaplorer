import 'package:flutter/material.dart';
import '../functions/payment_service.dart';

class SaveItinerary extends StatefulWidget {
  final String aiMessage

  SaveItinerary({required this.aiMessage, Key? Key}): super(key: Key);

  @override
  State<SaveItinerary> createState => SaveItineraryState();
}

class SaveItineraryState extends State<SaveItinerary>{

  @override
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
        crossAxisAlignment:
            isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          isAI ? MarkdownBody(data: message.text) : Text(message.text),
          if (isAI && !message.isInitialQuestion)
            IconButton(
              icon: Icon(
                message.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: message.isFavorite ? Colors.red : Colors.grey,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  message.isFavorite = !message.isFavorite;
                });
                print("Favorite toggled: ${message.isFavorite}");
              },
              padding: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
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

  Widget build(BuildContext context){
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