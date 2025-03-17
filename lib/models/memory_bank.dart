class MemoryBank {
  final int id;
  final int wordId;
  final int level; // 記憶レベル（0-5）
  final DateTime nextReviewDate;
  final DateTime lastReviewDate;
  final bool isActive;

  MemoryBank({
    required this.id,
    required this.wordId,
    required this.level,
    required this.nextReviewDate,
    required this.lastReviewDate,
    required this.isActive,
  });

  // 記憶レベルに基づく次回復習日を計算
  static DateTime calculateNextReviewDate(int level) {
    final now = DateTime.now();
    switch (level) {
      case 0:
        return now.add(const Duration(hours: 4)); // 4時間後
      case 1:
        return now.add(const Duration(days: 1)); // 1日後
      case 2:
        return now.add(const Duration(days: 3)); // 3日後
      case 3:
        return now.add(const Duration(days: 7)); // 1週間後
      case 4:
        return now.add(const Duration(days: 14)); // 2週間後
      case 5:
        return now.add(const Duration(days: 30)); // 1ヶ月後
      default:
        return now.add(const Duration(hours: 4));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word_id': wordId,
      'level': level,
      'next_review_date': nextReviewDate.toIso8601String(),
      'last_review_date': lastReviewDate.toIso8601String(),
      'is_active': isActive,
    };
  }

  static MemoryBank fromMap(Map<String, dynamic> map) {
    return MemoryBank(
      id: map['id'],
      wordId: map['word_id'],
      level: map['level'],
      nextReviewDate: DateTime.parse(map['next_review_date']),
      lastReviewDate: DateTime.parse(map['last_review_date']),
      isActive: map['is_active'],
    );
  }

  MemoryBank copyWith({
    int? id,
    int? wordId,
    int? level,
    DateTime? nextReviewDate,
    DateTime? lastReviewDate,
    bool? isActive,
  }) {
    return MemoryBank(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      level: level ?? this.level,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      isActive: isActive ?? this.isActive,
    );
  }
}