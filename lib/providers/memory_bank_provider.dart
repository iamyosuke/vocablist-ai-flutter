import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/memory_bank.dart';
import '../services/database_service.dart';

class MemoryBankProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<MemoryBank> _memoryBanks = [];
  bool _isInitialized = false;

  List<MemoryBank> get memoryBanks => _memoryBanks;
  bool get isInitialized => _isInitialized;

  // メモリバンクの初期化
  Future<void> initializeMemoryBank() async {
    if (_isInitialized) return;

    try {
      _memoryBanks = await _databaseService.getMemoryBanks();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing memory bank: $e');
      rethrow;
    }
  }

  // 新しい単語をメモリバンクに追加
  Future<void> addToMemoryBank(int wordId) async {
    final now = DateTime.now();
    final memoryBank = MemoryBank(
      id: 0, // Supabaseが自動的にIDを生成
      wordId: wordId,
      level: 0,
      nextReviewDate: MemoryBank.calculateNextReviewDate(0),
      lastReviewDate: now,
      isActive: true,
    );

    try {
      final id = await _databaseService.insertMemoryBank(memoryBank);
      final newMemoryBank = memoryBank.copyWith(id: id);
      _memoryBanks.add(newMemoryBank);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to memory bank: $e');
      rethrow;
    }
  }

  // 復習結果の更新
  Future<void> updateReviewResult(int memoryBankId, bool isCorrect) async {
    final index = _memoryBanks.indexWhere((mb) => mb.id == memoryBankId);
    if (index == -1) return;

    final memoryBank = _memoryBanks[index];
    final newLevel =
        isCorrect
            ? math.min(memoryBank.level + 1, 5)
            : math.max(memoryBank.level - 1, 0);

    final now = DateTime.now();
    final updatedMemoryBank = memoryBank.copyWith(
      level: newLevel,
      lastReviewDate: now,
      nextReviewDate: MemoryBank.calculateNextReviewDate(newLevel),
    );

    try {
      await _databaseService.updateMemoryBank(updatedMemoryBank);
      _memoryBanks[index] = updatedMemoryBank;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating memory bank: $e');
      rethrow;
    }
  }

  // 今日の復習対象の単語を取得
  List<MemoryBank> getTodayReviews() {
    final now = DateTime.now();
    return _memoryBanks
        .where((mb) => mb.isActive && mb.nextReviewDate.isBefore(now))
        .toList();
  }

  // 特定の単語の記憶状態を取得
  MemoryBank? getMemoryBankForWord(int wordId) {
    try {
      return _memoryBanks.firstWhere(
        (mb) => mb.wordId == wordId && mb.isActive,
      );
    } catch (_) {
      return null;
    }
  }
}
