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

class _WordDetailState extends State<WordDetail> {
  late TextEditingController _meaningController;
  late AudioPlayer _audioPlayer;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _meaningController = TextEditingController(text: widget.word.meaning);
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _meaningController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speakWord() async {
    try {
      // TextToSpeechを使用して単語を読み上げる
      // Note: 実際のTTS実装はプラットフォームに応じて異なります
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('音声の再生に失敗しました')));
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.deepPurple,
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.word.word,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              color: Colors.deepPurple,
                            ),
                            onPressed: _speakWord,
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
                  const SizedBox(height: 16),
                  if (_isEditing)
                    TextField(
                      controller: _meaningController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Enter meaning',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  else
                    MarkdownBody(
                      data: widget.word.meaning,
                      styleSheet: MarkdownStyleSheet(
                        h1: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        p: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    '作成日: ${widget.word.createdAt.toLocal()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '更新日: ${widget.word.updatedAt.toLocal()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
