import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';
import '../models/word.dart';

class WordDetail extends StatefulWidget {
  final Word word;
  final Function(Word) onWordUpdate;

  const WordDetail({super.key, required this.word, required this.onWordUpdate});

  @override
  State<WordDetail> createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetail> with SingleTickerProviderStateMixin {
  late TextEditingController _meaningController;
  late AudioPlayer _audioPlayer;
  bool _isEditing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _meaningController = TextEditingController(text: widget.word.meaning);
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _meaningController.dispose();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _speakWord() async {
    try {
      // TextToSpeechを使用して単語を読み上げる
      // Note: 実際のTTS実装はプラットフォームに応じて異なります
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('音声の再生に失敗しました')),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // 編集モードを終了時に変更を保存
        final updatedWord = widget.word.copyWith(
          meaning: _meaningController.text,
          updatedAt: DateTime.now(),
        );
        widget.onWordUpdate(updatedWord);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isEditing ? Icons.save : Icons.edit,
                              color: Colors.deepPurple,
                            ),
                            onPressed: _toggleEdit,
                          ),
                          if (!_isEditing)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // TODO: 削除機能の実装
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.word.word,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.volume_up,
                                  color: Colors.deepPurple.shade400,
                                  size: 28,
                                ),
                                onPressed: _speakWord,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_isEditing)
                            TextField(
                              controller: _meaningController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Enter meaning',
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            )
                          else
                            MarkdownBody(
                              data: widget.word.meaning,
                              styleSheet: MarkdownStyleSheet(
                                h1: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade400,
                                  height: 1.5,
                                ),
                                p: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          Text(
                            '作成日: ${widget.word.createdAt.toLocal()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '更新日: ${widget.word.updatedAt.toLocal()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}