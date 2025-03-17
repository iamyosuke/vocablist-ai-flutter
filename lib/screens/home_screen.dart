import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/database_service.dart';
import '../widgets/vocabulary_list.dart';
import '../widgets/word_detail.dart';
import '../widgets/add_word_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Word> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    try {
      final words = await _databaseService.getWords();
      setState(() {
        _words = words;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('単語の読み込みに失敗しました')),
      );
    }
  }

  Future<void> _addWord(Word word) async {
    try {
      final id = await _databaseService.insertWord(word);
      final newWord = word.copyWith(id: id);
      setState(() {
        _words.insert(0, newWord);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('単語の追加に失敗しました')),
      );
    }
  }

  Future<void> _updateWord(Word word) async {
    try {
      await _databaseService.updateWord(word);
      setState(() {
        final index = _words.indexWhere((w) => w.id == word.id);
        if (index != -1) {
          _words[index] = word;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('単語の更新に失敗しました')),
      );
    }
  }

  void _showWordDetail(Word word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordDetail(
          word: word,
          onWordUpdate: _updateWord,
        ),
      ),
    );
  }

  Future<void> _showAddWordDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddWordDialog(onWordAdd: _addWord),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocablist AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : VocabularyList(
              words: _words,
              onWordTap: _showWordDetail,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWordDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}