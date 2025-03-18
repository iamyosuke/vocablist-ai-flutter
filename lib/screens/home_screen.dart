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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  List<Word> _words = [];
  List<Word> _filteredWords = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadWords();
    _searchController.addListener(_filterWords);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterWords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWords = _words.where((word) {
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => WordDetail(
          word: word,
          onWordUpdate: _updateWord,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_stories,
                      color: Colors.deepPurple.shade400,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Vocablist AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Hero(
                  tag: 'searchBar',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search words...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.deepPurple.shade300,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple.shade300,
                          ),
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: VocabularyList(
                          words: _searchController.text.isEmpty
                              ? _words
                              : _filteredWords,
                          onWordTap: _showWordDetail,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: FloatingActionButton(
          onPressed: _showAddWordDialog,
          backgroundColor: Colors.deepPurple.shade400,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}