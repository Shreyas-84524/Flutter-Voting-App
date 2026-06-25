import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:civicvote/theme.dart';
import 'package:civicvote/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String voterId;

  const ProfileScreen({super.key, required this.voterId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('voters')
          .doc(voterId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          );
        }

        String name = "Verified Voter";
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('name')) {
            name = data['name'] as String? ?? "Verified Voter";
          }
        }

        return _buildProfileContent(context, name: name);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, {required String name}) {
    bool _notificationsEnabled = true;
    bool _isDarkMode = true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // User Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Icon(
              Icons.person_outline,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Name/Role
          Text(
            name,
            style: AppTypography.headlineMd.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Verified Elector',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          _buildGroupTitle('Account Settings'),
          _buildSettingsContainer(
            children: [
              _buildSettingsItem2(
                leadingIcon: Icons.person_outline,
                title: 'Voter ID',
                subtitle: '$voterId',
              ),
              _buildDivider(),
              _buildSettingsItem2(
                leadingIcon: Icons.lock_outline,
                title: 'Authentication',
                subtitle: 'Voter Card ID',
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
                    // setState(() {
                    //   _isDarkMode = value;
                    // });
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
                    // setState(() {
                    //   _notificationsEnabled = value;
                    // });
                  },
                  activeTrackColor: AppColors.primaryContainer.withOpacity(0.3),
                ),
              ),
              _buildDivider(),
              _buildSettingsItem2(
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
            ],
          ),
          SizedBox(height: 30),
          // Log Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate back to LoginScreen and clear nav stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Log Out of Portal',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.logout_outlined,
                    color: AppColors.error,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

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
                const SizedBox(height: 32),
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
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(children: children),
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

  Widget _buildSettingsItem2({
    required IconData leadingIcon,
    required String title,
    String? subtitle,

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
}
