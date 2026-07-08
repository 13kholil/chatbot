import "package:flutter/material.dart";
import "../models/chat_message.dart";

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSources;
  const MessageBubble({super.key, required this.message, this.showSources = true});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? Colors.blue.shade500 : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 64.0 : 16.0,
        right: isUser ? 16.0 : 64.0,
        top: 4, bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
              ),
            ),
            child: Text(message.content, style: TextStyle(color: textColor, fontSize: 15)),
          ),
          if (message.sources != null && message.sources!.isNotEmpty && showSources)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text("Sumber: " + message.sources!.join(", "),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ),
        ],
      ),
    );
  }
}
