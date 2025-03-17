import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memory_bank.dart';
import '../models/word.dart';
import '../services/database_service.dart';
import '../providers/memory_bank_provider.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Word> _reviewWords = [];
  List<MemoryBank> _reviewBanks = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isAnswerVisible = false;

  @override
  void initState() {
    super.initState();
    _loadReviewWords();
  }

  Future<void> _loadReviewWords() async {
    try {
      final memoryBankProvider = context.read<MemoryBankProvider>();
      final reviewBanks = memoryBankProvider.getTodayReviews();
      final words = await Future.wait(
        reviewBanks.map((bank) => _databaseService.getWord(bank.wordId)),
      );

      setState(() {
        _reviewBanks = reviewBanks;
        _reviewWords = words.whereType<Word>().toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('復習データの読み込みに失敗しました')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleResult(bool isCorrect) async {
    if (_currentIndex >= _reviewBanks.length) return;

    try {
      final memoryBankProvider = context.read<MemoryBankProvider>();
      await memoryBankProvider.updateReviewResult(
        _reviewBanks[_currentIndex].id,
        isCorrect,
      );

      setState(() {
        _isAnswerVisible = false;
        _currentIndex++;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('結果の保存に失敗しました')),
      );
    }
  }

  Widget _buildReviewCard() {
    if (_currentIndex >= _reviewWords.length) {
      return const Center(
        child: Text(
          '今日の復習は完了です！',
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    final word = _reviewWords[_currentIndex];
    final memoryBank = _reviewBanks[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            word.word,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_isAnswerVisible) ...[
            const Text('意味:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(word.meaning),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _handleResult(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('不正解'),
                ),
                ElevatedButton(
                  onPressed: () => _handleResult(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('正解'),
                ),
              ],
            ),
          ] else
            ElevatedButton(
              onPressed: () => setState(() => _isAnswerVisible = true),
              child: const Text('答えを表示'),
            ),
          const SizedBox(height: 16),
          Text(
            '記憶レベル: ${memoryBank.level}/5',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語の復習'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildReviewCard(),
    );
  }
}