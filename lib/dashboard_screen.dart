import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:civicvote/theme.dart';
import 'package:civicvote/live_update.dart';
import 'voting_analytics_services.dart';
import 'package:civicvote/election_time_manager.dart';

class DashboardScreen extends StatefulWidget {
  final String voterId;

  final String constituencyId;
  final bool hasVoted;
  final Function(int) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.voterId,
    required this.constituencyId,
    this.hasVoted = false,
    required this.onNavigateToTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedConstituencyId;

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

  String _formatNumber(int number) {
    final str = number.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match match) => '${match[1]},');
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
      default:
        return Icons.how_to_vote_rounded;
    }
  }

  Color _getCandidateColor(int index) {
    final colors = [
      AppColors.primaryContainer, // Amber
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final timeManager = ElectionTimeManager.instance;
    final isClosed = timeManager.isClosed;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('votes').snapshots(),
      builder: (context, votesSnapshot) {
        final totalVotesCast = votesSnapshot.hasData
            ? votesSnapshot.data!.docs.length
            : 245; // Fallback to mock baseline if empty
        final double turnoutRate = (totalVotesCast / 500.0) * 100.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header / Live Updates Alert
              Row(children: [LiveUpdatesBlinker()]),
              const SizedBox(height: 6),
              Text('Election Dashboard', style: AppTypography.headlineLg),
              const SizedBox(height: 24),

              // Live Countdown Widget
              if (!isClosed)
                _buildLiveCountdownWidget(timeManager.formattedRemaining),

              // Turnout stats grid (always visible)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: Future.wait([
                  VotingAnalyticsService().calculateGrandTotalTurnout(),
                  VotingAnalyticsService().calculateRegionalTurnout(
                    _selectedConstituencyId ?? 'dahisar',
                  ),
                ]),
                builder: (context, analyticsSnapshot) {
                  if (analyticsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      height: 120,
                      alignment: Alignment.center,
                      decoration: AppDecorations.glassPanel(borderRadius: 16),
                      child: const CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                      ),
                    );
                  }

                  if (analyticsSnapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: AppDecorations.glassPanel(borderRadius: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Election results',
                            style: AppTypography.headlineSm,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Error loading metrics: ${analyticsSnapshot.error}',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final grandData = analyticsSnapshot.data![0];
                  final regionalData = analyticsSnapshot.data![1];

                  final grandVotes = grandData['grandTotalVotes'] as int;
                  final grandTurnout =
                      grandData['grandTotalTurnoutPercent'] as double;

                  final regionalVotes = regionalData['totalVotesCast'] as int;
                  final regionalTurnout =
                      regionalData['turnoutPercent'] as double;

                  final targetConstituencyId =
                      _selectedConstituencyId ?? 'dahisar';
                  String constituencyLabel = targetConstituencyId;
                  if (constituencyLabel.isNotEmpty) {
                    constituencyLabel =
                        constituencyLabel[0].toUpperCase() +
                        constituencyLabel.substring(1);
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.glassPanel(borderRadius: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Election results',
                          style: AppTypography.headlineSm,
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatItem(
                              Icons.how_to_vote_sharp,
                              _formatNumber(grandVotes),
                              'Total Votes',
                              AppColors.primaryContainer,
                            ),
                            _buildStatItem(
                              Icons.account_balance_sharp,
                              '${grandTurnout.toStringAsFixed(1)} %',
                              'Total Turnout',
                              AppColors.primaryContainer,
                            ),
                            _buildStatItem(
                              Icons.how_to_vote_sharp,
                              _formatNumber(regionalVotes),
                              '$constituencyLabel Votes',
                              AppColors.primaryContainer,
                            ),
                            _buildStatItem(
                              Icons.account_balance_sharp,
                              '${regionalTurnout.toStringAsFixed(1)} %',
                              '$constituencyLabel Turnout',
                              AppColors.primaryContainer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Dynamic Layout grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final Widget resultsOrPlaceholder =
                      _buildDynamicStandingsCard();

                  if (constraints.maxWidth >= 600) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: resultsOrPlaceholder),
                        const SizedBox(width: 20),
                        Expanded(flex: 1, child: _buildYourBallotCard()),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        resultsOrPlaceholder,
                        const SizedBox(height: 20),
                        _buildYourBallotCard(),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Portal Metrics Card
              _buildPortalMetricsCard(turnoutRate),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Standings widget displaying candidate list from Firestore
  Widget _buildDynamicStandingsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('constituencies')
          .snapshots(),
      builder: (context, constituencySnapshot) {
        if (constituencySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          );
        }

        if (constituencySnapshot.hasError ||
            !constituencySnapshot.hasData ||
            constituencySnapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Failed to load constituencies.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.error),
            ),
          );
        }

        final constituencies = constituencySnapshot.data!.docs;

        // If selected constituency is null or not in the fetched list, default to the first one
        if (_selectedConstituencyId == null ||
            !constituencies.any((doc) => doc.id == _selectedConstituencyId)) {
          _selectedConstituencyId = constituencies.first.id;
        }

        final currentConstituencyDoc = constituencies.firstWhere(
          (doc) => doc.id == _selectedConstituencyId,
        );
        final currentConstituencyName =
            currentConstituencyDoc.get('name') as String? ??
            _selectedConstituencyId!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Constituency Selector Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.glassPanel(borderRadius: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Constituency',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedConstituencyId,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryContainer,
                        ),
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                        items: constituencies.map((doc) {
                          final name = doc.get('name') as String? ?? doc.id;
                          final isUserConstituency =
                              doc.id == widget.constituencyId;
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Row(
                              children: [
                                Text(name),
                                if (isUserConstituency) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Your District',
                                      style: AppTypography.labelSm.copyWith(
                                        color: AppColors.secondary,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedConstituencyId = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Candidates Tally Card
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('constituencies')
                  .doc(_selectedConstituencyId)
                  .collection('candidates')
                  .snapshots(),
              builder: (context, candidateSnapshot) {
                if (candidateSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  );
                }

                if (candidateSnapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: AppDecorations.glassPanel(borderRadius: 16),
                    child: Center(
                      child: Text(
                        'Failed to load standings: ${candidateSnapshot.error}',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  );
                }

                if (!candidateSnapshot.hasData ||
                    candidateSnapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.glassPanel(borderRadius: 16),
                    child: const Center(
                      child: Text('No candidates found for this constituency.'),
                    ),
                  );
                }

                final candidates = candidateSnapshot.data!.docs;

                // Calculate total votes in this constituency
                int totalConstituencyVotes = 0;
                for (var doc in candidates) {
                  totalConstituencyVotes += (doc.get('votes') as int? ?? 0);
                }

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.glassPanel(borderRadius: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$currentConstituencyName Standings',
                              style: AppTypography.headlineSm.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatNumber(totalConstituencyVotes),
                                style: AppTypography.headlineSm.copyWith(
                                  color: AppColors.primaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Votes Cast',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: candidates.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final candidateDoc = candidates[index];
                          final name =
                              candidateDoc.get('name') as String? ?? 'Unknown';
                          final party =
                              candidateDoc.get('party') as String? ??
                              'Independent';
                          final partySign =
                              candidateDoc.get('partySign') as String? ?? '';
                          final votes = candidateDoc.get('votes') as int? ?? 0;

                          final percent = totalConstituencyVotes > 0
                              ? (votes / totalConstituencyVotes) * 100
                              : 0.0;
                          final color = _getCandidateColor(index);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: color.withValues(
                                      alpha: 0.15,
                                    ),
                                    child: Icon(
                                      _getPartyIcon(
                                        partySign.isNotEmpty
                                            ? partySign
                                            : party,
                                      ),
                                      color: color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: AppTypography.labelMd.copyWith(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          party,
                                          style: AppTypography.labelSm.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${percent.toStringAsFixed(1)}%',
                                        style: AppTypography.headlineSm
                                            .copyWith(
                                              color: color,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${_formatNumber(votes)} votes',
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 8,
                                  width: double.infinity,
                                  child: Stack(
                                    children: [
                                      Container(
                                        color:
                                            AppColors.surfaceContainerHighest,
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: totalConstituencyVotes > 0
                                            ? (percent / 100)
                                            : 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Your Ballot section with conditional state mapping
  Widget _buildYourBallotCard() {
    if (ElectionTimeManager.instance.isClosed) {
      return _buildVotingConcludedNotification();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('voters')
          .doc(widget.voterId)
          .snapshots(),
      builder: (context, snapshot) {
        final hasVoted = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.get('hasVoted') as bool? ?? false)
            : false;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.glassPanel(borderRadius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Your Ballot', style: AppTypography.headlineSm),
                  SizedBox(width: 6),
                  const Icon(
                    Icons.ballot_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              SizedBox(height: 20),

              InkWell(
                onTap: () {
                  // Direct navigation to Vote Tab (Index 1)
                  widget.onNavigateToTab(1);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasVoted
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.primaryContainer.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: hasVoted
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AppColors.primaryContainer.withValues(
                                      alpha: 0.1,
                                    ),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: hasVoted
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : AppColors.primaryContainer.withValues(
                                        alpha: 0.2,
                                      ),
                              ),
                            ),
                            child: Text(
                              hasVoted ? 'Voted' : 'Pending Action',
                              style: AppTypography.labelSm.copyWith(
                                color: hasVoted
                                    ? AppColors.onSurfaceVariant
                                    : AppColors.primaryContainer,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            hasVoted ? Icons.check_circle : Icons.arrow_forward,
                            color: hasVoted
                                ? AppColors.secondary
                                : AppColors.primaryContainer,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'District Candidate Election',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasVoted
                            ? 'Your dynamic ballot has been submitted successfully.'
                            : 'Review candidates registered in your district and cast your secure vote.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Quick Stats Grid
  Widget _buildPortalMetricsCard(double turnoutRate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.glassPanel(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portal Metrics', style: AppTypography.headlineSm),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
            children: [
              _buildStatItem(
                Icons.how_to_vote,
                ElectionTimeManager.instance.isClosed
                    ? '00:00:00'
                    : ElectionTimeManager.instance.formattedRemaining,
                ElectionTimeManager.instance.isClosed
                    ? 'Voting Concluded'
                    : 'Time Remaining',
                AppColors.primaryContainer,
              ),
            ],
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatItem(
                Icons.verified_user_outlined,
                '99.9%',
                'System Uptime',
                AppColors.primaryContainer,
              ),
              _buildStatItem(
                Icons.account_balance_rounded,
                '10',
                'Total Districts',
                AppColors.primaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String val,
    String desc,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            val,
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCountdownWidget(String formattedTime) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration:
          AppDecorations.glassPanel(
            borderRadius: 16,
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
          ).copyWith(
            border: Border.all(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VOTING WINDOW ACTIVE',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primaryContainer,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ballot closes soon. Cast your vote before the deadline.',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedTime,
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'Time Remaining',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVotingConcludedNotification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          const Icon(
            Icons.verified_outlined,
            color: AppColors.primaryContainer,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Voting Concluded',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voting has officially concluded for this cycle. Thank you for making your voice heard!',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
