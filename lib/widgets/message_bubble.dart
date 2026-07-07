import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSources;

  const MessageBubble({
    super.key,
    required this.message,
    this.showSources = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
          child: MarkdownBody(
            data: message.content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
              strong: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    final isUser = message.isUser;
    final isError = message.isError;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 56 : 12,
        right: isUser ? 12 : 56,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isError
                  ? theme.colorScheme.errorContainer
                  : isUser
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            child: isUser
                ? Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onPrimaryContainer,
                      height: 1.4,
                    ),
                  )
                : MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 14,
                        color: isError
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onSurface,
                        height: 1.5,
                      ),
                      strong: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      code: TextStyle(
                        fontSize: 12,
                        backgroundColor: Colors.grey.shade200,
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                      h1: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      h2: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      h3: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      listBullet: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
          ),
          if (!isUser && showSources && message.sources != null && message.sources!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: message.sources!.map((source) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      source,
                      style: TextStyle(
                        fontSize: 9,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
