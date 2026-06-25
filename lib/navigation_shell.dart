import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:civicvote/theme.dart';
import 'package:civicvote/dashboard_screen.dart';
import 'package:civicvote/vote_screen.dart';
import 'package:civicvote/profile_screen.dart';

class NavigationShell extends StatefulWidget {
  final String voterId;

  const NavigationShell({super.key, required this.voterId});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('voters')
          .doc(widget.voterId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryContainer,
              ),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return _buildShell(
            context,
            constituencyId: 'dahisar',
            hasVoted: false,
          );
        }
        final data = snapshot.data!;
        final constituencyId =
            data.get('constituencyId') as String? ?? 'dahisar';
        final hasVoted = data.get('hasVoted') as bool? ?? false;
        return _buildShell(
          context,
          constituencyId: constituencyId,
          hasVoted: hasVoted,
        );
      },
    );
  }

  Widget _buildShell(
    BuildContext context, {
    required String constituencyId,
    required bool hasVoted,
  }) {
    // List of screens
    final List<Widget> tabs = [
      DashboardScreen(
        voterId: widget.voterId,

        constituencyId: constituencyId,
        hasVoted: hasVoted,
        onNavigateToTab: _navigateToTab,
      ),
      VoteScreen(
        voterId: widget.voterId,
        constituencyId: constituencyId,
        hasVoted: hasVoted,
        onNavigateToTab: _navigateToTab,
      ),
      ProfileScreen(voterId: widget.voterId),
    ];

    // Mobile layout (Bottom Navigation + Top Bar)
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'CivicVote',
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.primaryContainer,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications.'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Side Navigation Menu (Web View)

  // Bottom Navigation Menu (Mobile View)
  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _navigateToTab,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryContainer,
            unselectedItemColor: AppColors.onSurfaceVariant,
            selectedLabelStyle: AppTypography.labelSm.copyWith(
              color: AppColors.primaryContainer,
            ),
            unselectedLabelStyle: AppTypography.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.how_to_vote_outlined),
                activeIcon: Icon(Icons.how_to_vote),
                label: 'Vote',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
