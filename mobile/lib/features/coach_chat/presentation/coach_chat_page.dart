import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:levelup_creator/core/theme/app_colors.dart';
import 'package:levelup_creator/core/constants/app_constants.dart';

class CoachChatPage extends ConsumerStatefulWidget {
  const CoachChatPage({super.key});
  @override
  ConsumerState<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends ConsumerState<CoachChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  List<Map<String, String>> _messages = [];
  bool _loading = true;

  final _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return;

      final response = await _dio.get(
        '/coach/history',
        options: Options(headers: {'Authorization': 'Bearer ${session.accessToken}'}),
      );

      final data = response.data['messages'] as List;
      if (mounted) {
        setState(() {
          if (data.isEmpty) {
            _messages = [{
              'role': 'assistant',
              'content': '¡Hola! 🎉 Soy tu Coach de IA en LevelUp Creator.\n\nEstoy aquí para ayudarte a crecer como creador de contenido.\n\n¿Por dónde empezamos?',
            }];
          } else {
            _messages = data.map((m) => {
              'role': m['role'].toString(),
              'content': m['content'].toString(),
            }).toList();
          }
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _sending = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    try {
      final session = Supabase.instance.client.auth.currentSession;
      final response = await _dio.post(
        '/coach/chat',
        data: {'message': text, 'language': 'es'},
        options: Options(headers: {'Authorization': 'Bearer ${session?.accessToken}'}),
      );

      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': response.data['response'].toString(),
          });
          _sending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Lo siento, hubo un error al conectar con el servidor.',
          });
          _sending = false;
        });
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LevelUp Coach', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    const Text('Online', style: TextStyle(fontSize: 11, color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _sending) {
                  return _TypingIndicator();
                }
                final msg = _messages[index];
                return _ChatBubble(
                  content: msg['content']!,
                  isUser: msg['role'] == 'user',
                );
              },
            ),
          ),
          // Input
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Pregunta algo a tu coach...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sending ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;

  const _ChatBubble({required this.content, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.primaryGradient : null,
          color: isUser ? null : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 200),
            const SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (c) => c.repeat())
      .fadeIn(delay: Duration(milliseconds: delay))
      .then()
      .fadeOut();
  }
}
