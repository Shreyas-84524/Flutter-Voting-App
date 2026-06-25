import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:civicvote/theme.dart';

class Profile2Screen extends StatefulWidget {
  const Profile2Screen({super.key});

  @override
  State<Profile2Screen> createState() => _Profile2ScreenState();
}

class _Profile2ScreenState extends State<Profile2Screen> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  int _currentIndex = 3; // Profile tab is active by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        leadingWidth: 56,
        leading: const Center(
          child: Icon(
            Icons.shield_outlined,
            color: AppColors.primaryContainer,
            size: 26,
          ),
        ),
        title: Text(
          'CivicVote',
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top padding for the sticky app bar
              const SizedBox(height: kToolbarHeight + 40),

              // User Profile Section
              _buildProfileCard(),
              const SizedBox(height: 16),

              // Account Settings
              _buildGroupTitle('Account Settings'),
              _buildSettingsContainer(
                children: [
                  _buildSettingsItem(
                    leadingIcon: Icons.person_outline,
                    title: 'Personal Information',
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    leadingIcon: Icons.lock_outline,
                    title: 'Security & Authentication',
                    subtitle: 'Face ID Enabled',
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    leadingIcon: Icons.history,
                    title: 'Voting History',
                  ),
                ],
              ),

              // App Settings
              _buildGroupTitle('App Settings'),
              _buildSettingsContainer(
                children: [
                  _buildSettingsItem(
                    leadingIcon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _isDarkMode = value;
                        });
                      },
                      activeColor: AppColors.primaryContainer,
                      activeTrackColor: AppColors.primaryContainer.withOpacity(0.3),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    leadingIcon: Icons.notifications_active_outlined,
                    title: 'Notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeColor: AppColors.primaryContainer,
                      activeTrackColor: AppColors.primaryContainer.withOpacity(0.3),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    leadingIcon: Icons.language,
                    title: 'Language',
                    subtitle: 'English (US)',
                  ),
                ],
              ),

              // Support & Legal
              _buildGroupTitle('Support & Legal'),
              _buildSettingsContainer(
                children: [
                  _buildSettingsItem(
                    leadingIcon: Icons.help_outline,
                    title: 'Help Center',
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    leadingIcon: Icons.description_outlined,
                    title: 'Terms of Service',
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    leadingIcon: Icons.logout,
                    title: 'Log Out',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    trailing: const SizedBox.shrink(),
                  ),
                ],
              ),

              // App Version
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      'CivicVote v2.4.0-build.82',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ENCRYPTED END-TO-END',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant.withOpacity(0.3),
                        letterSpacing: 2.5,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom offset for navigation bar
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.8),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.how_to_vote_outlined, 'Vote'),
                _buildNavItem(2, Icons.analytics_outlined, 'Results'),
                _buildNavItem(3, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x991E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryContainer,
                    width: 2.0,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  backgroundImage: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBHuTVMHaTCC_Wprb88WIzv-dYyNg6ottUxZdWVQPwdTep370a96y3dSwGBQKwpePkeqkZ-xalgf_C5smf6J4rVvma_L5GinyJ_vG7M-XpgZqZU8HlIemSyWH2MVOssS1oAwwVlTnyRWdsQBCWVRp-EcMplNKJ6U3tMAg_nP6P3kHAOyLxuqMTUYKAjzOY1R-7U7cLtg4jnJPF2FTXcrWKZeYdAik3k2H1BRAZvlFdgNv8vbA3wvNXeh8yX0Frm-fBZNKMvuXmrZis',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.verified,
                      size: 12,
                      color: AppColors.onSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alexander Pierce',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant.withOpacity(0.7),
                    ),
                    children: [
                      const TextSpan(text: 'Voter ID: '),
                      TextSpan(
                        text: 'V-9823-4410',
                        style: GoogleFonts.firaCode(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 24.0),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSm.copyWith(
          color: AppColors.onSurfaceVariant.withOpacity(0.6),
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x991E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData leadingIcon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              leadingIcon,
              color: iconColor ?? AppColors.primaryContainer,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppColors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    final Color color = isActive ? AppColors.primaryContainer : AppColors.onSurfaceVariant;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
