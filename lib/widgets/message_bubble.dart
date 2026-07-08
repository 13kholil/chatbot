import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showSources;

  const MessageBubble({
    super.key,
    required this.message,
    this.showSources = true,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _sourcesExpanded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (widget.message.isSystem) {
      return FadeTransition(opacity: _fadeAnimation, child: _buildSystemMessage(colorScheme),);
    }

    final isUser = widget.message.isUser;
    final isError = widget.message.isError;
    final isStreaming = widget.message.isStreaming;
  
    return SlideTransition(position: _slideAnimation, child: FadeTransition(opacity: _fadeAnimation, child: _buildBubble(isUser, isError, isStreaming, isDark, colorScheme)));
  }

  Widget _buildSystemMessage(ColorScheme colorScheme) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Container());
  }

  Widget _buildBubble(bool isUser, bool isError, bool isStreaming, bool isDark, ColorScheme colorScheme) {
    return const SizedBox.shrink();
  }
}
