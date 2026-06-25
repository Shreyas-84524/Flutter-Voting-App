import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:civicvote/theme.dart';
import 'package:civicvote/vote_thanks_screen.dart';
import 'package:civicvote/election_time_manager.dart';

class VoteScreen extends StatefulWidget {
  final String voterId;
  final String constituencyId;
  final bool hasVoted;
  final Function(int) onNavigateToTab;

  const VoteScreen({
    super.key,
    required this.voterId,
    required this.constituencyId,
    required this.hasVoted,
    required this.onNavigateToTab,
  });

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  String? _selectedCandidateId;
  String? _selectedCandidateName;
  String? _selectedPartyName;
  String? _selectedPartySign;
  bool _isSubmitting = false;

  // Local state to show thanks screen right after successful transaction
  bool _voteSubmittedSuccessfully = false;

  @override
  void initState() {
    super.initState();
    ElectionTimeManager.instance.addListener(_onTimeChanged);
  }

  @override
  void dispose() {
    ElectionTimeManager.instance.removeListener(_onTimeChanged);
    super.dispose();
  }

  void _onTimeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  IconData _getPartyIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'run_circle_outlined':
        return Icons.run_circle_outlined;
      case 'person_outline_rounded':
        return Icons.person_outline_rounded;
      case 'window_sharp':
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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitBallot() async {
    if (_selectedCandidateId == null || _isSubmitting) return;

    if (ElectionTimeManager.instance.isClosed) {
      _showErrorDialog(
        'Voting Closed',
        'Voting has closed. This ballot can no longer be processed.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final voterRef = FirebaseFirestore.instance
        .collection('voters')
        .doc(widget.voterId);
    final candidateRef = FirebaseFirestore.instance
        .collection('constituencies')
        .doc(widget.constituencyId)
        .collection('candidates')
        .doc(_selectedCandidateId);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? widget.voterId;
    final voteRef = FirebaseFirestore.instance.collection('votes').doc(userId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Reads must happen first in a transaction
        final voterSnap = await transaction.get(voterRef);
        final candidateSnap = await transaction.get(candidateRef);

        if (!voterSnap.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
            message: 'Voter profile record not found.',
          );
        }
        if (!candidateSnap.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
            message: 'Selected candidate record not found.',
          );
        }

        final hasVoted = voterSnap.get('hasVoted') as bool? ?? false;
        if (hasVoted) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'already-voted',
            message:
                'Your voter registration ID has already cast a ballot in this election.',
          );
        }

        // Writes
        transaction.update(voterRef, {'hasVoted': true});
        transaction.update(candidateRef, {'votes': FieldValue.increment(1)});
        transaction.set(voteRef, {
          'voterId': widget.voterId,
          'uid': FirebaseAuth.instance.currentUser?.uid,
          'constituencyId': widget.constituencyId,
          'candidateId': _selectedCandidateId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _voteSubmittedSuccessfully = true;
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        String title = 'Voting Error';
        String msg =
            e.message ?? 'An error occurred while processing your ballot.';
        if (e.code == 'already-voted') {
          title = 'Double-Voting Intercepted';
        } else if (e.code == 'permission-denied') {
          title = 'Security Verification Failed';
          msg = 'Voting has closed. This ballot can no longer be processed.';
        }
        _showErrorDialog(title, msg);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog(
          'Unexpected Error',
          'A system error occurred: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasVoted || _voteSubmittedSuccessfully) {
      return VoteThanksScreen(
        candidateName: _selectedCandidateName,
        partyName: _selectedPartyName,
        partySign: _selectedPartySign,
        onNavigateToTab: widget.onNavigateToTab,
      );
    }

    if (ElectionTimeManager.instance.isClosed) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _buildVotingConcludedNotification(),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('constituencies')
          .doc(widget.constituencyId)
          .collection('candidates')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to retrieve candidate lists: ${snapshot.error}',
              style: AppTypography.bodyLg.copyWith(color: AppColors.error),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No candidates registered for your district.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.error),
            ),
          );
        }

        final candidates = snapshot.data!.docs;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cast Your Ballot', style: AppTypography.headlineLg),
              const SizedBox(height: 8),
              Text(
                'Select your candidate choice below and submit. Your ballot is cryptographic and anonymous.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Proposal Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.glassPanel(borderRadius: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Active Ballot: District Candidate Election',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Constituency Representative',
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose a candidate to represent your district. This vote is final and can only be cast once.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 16),

                    // Candidates choices
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: candidates.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final candidateDoc = candidates[index];
                        final id = candidateDoc.id;
                        final name =
                            candidateDoc.get('name') as String? ?? 'Candidate';
                        final party =
                            candidateDoc.get('party') as String? ??
                            'Independent';
                        final partySign =
                            candidateDoc.get('partySign') as String? ?? '';

                        return _buildVoteOption(
                          id: id,
                          name: name,
                          party: party,
                          partySign: partySign,
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _selectedCandidateId == null || _isSubmitting
                            ? null
                            : AppDecorations.primaryGlow(),
                      ),
                      child: ElevatedButton(
                        onPressed: _selectedCandidateId == null || _isSubmitting
                            ? null
                            : _submitBallot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor:
                              AppColors.surfaceContainerHigh,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text(
                                'Submit Private Ballot',
                                style: AppTypography.headlineSm.copyWith(
                                  color: _selectedCandidateId == null
                                      ? AppColors.onSurfaceVariant
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoteOption({
    required String id,
    required String name,
    required String party,
    required String partySign,
  }) {
    final bool isSelected = _selectedCandidateId == id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCandidateId = id;
          _selectedCandidateName = name;
          _selectedPartyName = party;
          _selectedPartySign = partySign;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.06)
              : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              child: Icon(
                _getPartyIcon(partySign.isNotEmpty ? partySign : party),
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.onSurfaceVariant,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    party,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingConcludedNotification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration:
          AppDecorations.glassPanel(
            borderRadius: 16,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.05),
          ).copyWith(
            border: Border.all(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_outlined,
            color: AppColors.primaryContainer,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Voting Concluded',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Voting has officially concluded for this cycle. Thank you for making your voice heard!',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
