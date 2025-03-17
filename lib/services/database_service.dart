import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word.dart';
import '../models/memory_bank.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  // Word関連のメソッド
  Future<int> insertWord(Word word) async {
    final response = await _supabase.from('words').insert({
      'word': word.word,
      'meaning': word.meaning,
      'created_at': word.createdAt.toIso8601String(),
      'updated_at': word.updatedAt.toIso8601String(),
    }).select();

    return response[0]['id'] as int;
  }

  Future<List<Word>> getWords() async {
    final response = await _supabase
        .from('words')
        .select()
        .order('created_at', ascending: false);

    return response.map((data) => Word.fromMap(data)).toList();
  }

  Future<Word?> getWord(int id) async {
    final response = await _supabase
        .from('words')
        .select()
        .eq('id', id)
        .single();

    return response == null ? null : Word.fromMap(response);
  }

  Future<void> updateWord(Word word) async {
    final id = word.id;
    if (id == null) {
      throw Exception('Word ID cannot be null for update operation');
    }

    await _supabase
        .from('words')
        .update({
          'meaning': word.meaning,
          'updated_at': word.updatedAt.toIso8601String(),
        })
        .eq('id', id);
  }

  Future<void> deleteWord(int id) async {
    await _supabase
        .from('words')
        .delete()
        .eq('id', id);
  }

  // MemoryBank関連のメソッド
  Future<int> insertMemoryBank(MemoryBank memoryBank) async {
    final response = await _supabase.from('memory_banks').insert({
      'word_id': memoryBank.wordId,
      'level': memoryBank.level,
      'next_review_date': memoryBank.nextReviewDate.toIso8601String(),
      'last_review_date': memoryBank.lastReviewDate.toIso8601String(),
      'is_active': memoryBank.isActive,
    }).select();

    return response[0]['id'] as int;
  }

  Future<List<MemoryBank>> getMemoryBanks() async {
    final response = await _supabase
        .from('memory_banks')
        .select()
        .eq('is_active', true)
        .order('next_review_date', ascending: true);

    return response.map((data) => MemoryBank.fromMap(data)).toList();
  }

  Future<void> updateMemoryBank(MemoryBank memoryBank) async {
    await _supabase
        .from('memory_banks')
        .update({
          'level': memoryBank.level,
          'next_review_date': memoryBank.nextReviewDate.toIso8601String(),
          'last_review_date': memoryBank.lastReviewDate.toIso8601String(),
          'is_active': memoryBank.isActive,
        })
        .eq('id', memoryBank.id);
  }
}
