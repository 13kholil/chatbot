import "dart:math";
import "package:flutter/material.dart";
import "../models/chat_message.dart";

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showSources;

  const MessageBubble({super.key, required this.message, this.showSources = true});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _showSourcesLocal = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    if (widget.message.isStreaming && widget.message.content.isEmpty) {
      _animCtrl.repeat();
    } else {
      _animCtrl.forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: widget.message.isSystem
            ? _buildSystemMessage()
            : widget.message.isUser
                ? _buildUserBubble()
                : _buildAssistantBubble(context),
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          widget.message.content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.indigo.shade700, height: 1.5),
        ),
      ),
    );
  }

  Widget _buildUserBubble() {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              widget.message.content,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(widget.message.timestamp),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
  Widget _buildErrorHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 14, color: Colors.red.shade400),
          const SizedBox(width: 6),
          Text("Terjadi kesalahan",
              style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(3, (i) => _dot(i)),
        const SizedBox(width: 6),
        Text("Mengetik...",
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, child) {
        final delay = index * 0.15;
        final t = (_animCtrl.value - delay).clamp(0.0, 1.0);
        final pulse = sin(t * 3.14159 * 2) * 0.5 + 0.5;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6 + (pulse * 4),
          height: 6 + (pulse * 4),
          decoration: BoxDecoration(
            color: Colors.indigo.shade400.withValues(alpha: 0.4 + (pulse * 0.6)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
  Widget _buildAssistantBubble(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.grey.shade900;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 64, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: const Radius.circular(4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.message.isError) _buildErrorHeader(),
                      if (widget.message.isStreaming && widget.message.content.isEmpty)
                        _buildTypingIndicator()
                      else
                        Text(
                          widget.message.content,
                          style: TextStyle(fontSize: 15, height: 1.4, color: textColor),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!widget.message.isStreaming)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 2),
              child: Text(
                _formatTime(widget.message.timestamp),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ),
          if (widget.message.sources != null &&
              widget.message.sources!.isNotEmpty &&
              widget.showSources)
            _buildSourcesToggle(theme),
        ],
      ),
    );
  }
  Widget _buildSourcesToggle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showSourcesLocal = !_showSourcesLocal),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.source_rounded, size: 13, color: Colors.indigo.shade400),
                  const SizedBox(width: 4),
                  Text("Sumber (${widget.message.sources!.length})",
                      style: TextStyle(fontSize: 11, color: Colors.indigo.shade600)),
                  const SizedBox(width: 4),
                  Icon(
                    _showSourcesLocal
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 16,
                    color: Colors.indigo.shade400,
                  ),
                ],
              ),
            ),
          ),
          if (_showSourcesLocal)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Referensi:",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade900)),
                    const SizedBox(height: 4),
                    ...widget.message.sources!.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text("• $s",
                              style: TextStyle(fontSize: 11, color: Colors.amber.shade800)),
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }
}