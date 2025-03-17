import 'package:flutter/material.dart';
import '../models/word.dart';

class VocabularyList extends StatelessWidget {
  final List<Word> words;
  final Function(Word) onWordTap;

  const VocabularyList({
    super.key,
    required this.words,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              word.word,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              word.meaning.split('\n').first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onWordTap(word),
          ),
        );
      },
    );
  }
}