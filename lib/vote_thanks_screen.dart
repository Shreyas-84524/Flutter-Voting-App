import 'package:flutter/material.dart';
import 'package:civicvote/theme.dart';

class VoteThanksScreen extends StatelessWidget {
  final String? candidateName;
  final String? partyName;
  final String? partySign;
  final Function(int) onNavigateToTab;

  const VoteThanksScreen({
    super.key,
    this.candidateName,
    this.partyName,
    this.partySign,
    required this.onNavigateToTab,
  });

  IconData _getPartyIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'run_circle_outlined':
        return Icons.run_circle_outlined;
      case 'person_outline_rounded':
      case 'independent':
      case 'independent candidates':
        return Icons.person_outline_rounded;
      case 'window_sharp':
      case 'window':
      case 'window party':
        return Icons.window_sharp;
      case 'local_fire_department_rounded':
        return Icons.local_fire_department_rounded;
      case 'eco_rounded':
        return Icons.eco_rounded;
      case 'water_drop_rounded':
        return Icons.water_drop_rounded;
      case 'star_rounded':
        return Icons.star_rounded;
      case 'shield_rounded':
        return Icons.shield_rounded;
      case 'favorite_rounded':
        return Icons.favorite_rounded;
      case 'lightbulb_rounded':
        return Icons.lightbulb_rounded;
      default:
        return Icons.how_to_vote_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool justVoted = candidateName != null && candidateName!.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.secondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ballot Cast Successfully',
              style: AppTypography.headlineLg,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              justVoted
                  ? 'Your vote has been securely recorded on the decentralized, tamper-proof ledger.'
                  : 'Your precinct voting record indicates your ballot has already been submitted and verified.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (justVoted) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.surfaceContainerHigh,
                  child: Column(
                    children: [
                      Text(
                        'RECEIPT OF SELECTION',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primaryContainer,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getPartyIcon(
                              (partySign != null && partySign!.isNotEmpty)
                                  ? partySign!
                                  : (partyName ?? ''),
                            ),
                            color: AppColors.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                candidateName!,
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                partyName ?? 'Independent',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            ElevatedButton(
              onPressed: () => onNavigateToTab(0), // Back to dashboard
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'View Dashboard',
                style: AppTypography.labelMd.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
