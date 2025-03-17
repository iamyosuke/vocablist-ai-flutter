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
  List<Word> _filteredWords = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWords();
    _searchController.addListener(_filterWords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWords =
          _words.where((word) {
            return word.word.toLowerCase().contains(query) ||
                word.meaning.toLowerCase().contains(query);
          }).toList();
    });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('単語の読み込みに失敗しました')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('単語の追加に失敗しました')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('単語の更新に失敗しました')));
    }
  }

  void _showWordDetail(Word word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordDetail(word: word, onWordUpdate: _updateWord),
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
        title: const Text(
          'Vocablist AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search words...',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : VocabularyList(
                      words:
                          _searchController.text.isEmpty
                              ? _words
                              : _filteredWords,
                      onWordTap: _showWordDetail,
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWordDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
