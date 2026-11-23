import 'package:flutter/material.dart';

import '../game/game_options.dart';
import '../game/saved_game_repository.dart';
import '../l10n/localized_labels.dart';

class ContinueCard extends StatelessWidget {
  const ContinueCard({
    super.key,
    required this.savedGame,
    required this.difficultyName,
    required this.onTap,
    this.puzzleName,
  });

  final SavedGameSummary savedGame;
  final String difficultyName;
  final VoidCallback? onTap;
  final String? puzzleName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percentFilled = (savedGame.fillProgress * 100).round();
    final strings = context.strings;
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.continueGame, style: textTheme.titleMedium),
                    Text(
                      [
                        ?puzzleName,
                        '${savedGame.size}×${savedGame.size}',
                        difficultyName,
                        formatElapsedTime(savedGame.elapsed),
                      ].join(' · '),
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: savedGame.fillProgress,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                strings.percentFilled(percentFilled),
                style: textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
