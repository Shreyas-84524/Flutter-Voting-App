import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:civicvote/theme.dart';
import 'package:civicvote/navigation_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';

///Parameters for Responsive App

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _voterIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _voterIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.onErrorContainer),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final voterId = _voterIdController.text.trim();
      final password = _passwordController.text;
      final email = '$voterId@civicvote.app';

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationShell(voterId: voterId),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          String errorMessage = 'Authentication failed.';
          if (e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-credential') {
            errorMessage = 'Invalid Voter ID or Password.';
          } else if (e.code == 'network-request-failed') {
            errorMessage = 'Network error. Please check your connection.';
          } else if (e.message != null) {
            errorMessage = e.message!;
          }
          _showErrorSnackBar(errorMessage);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('An unexpected error occurred: ${e.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Scrollable Body
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Section
                    SizedBox(height: 20),
                    Text(
                      'CivicVote',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Secure. Transparent. Democratic.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Glass Card Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppDecorations.glassPanel(borderRadius: 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Voter ID Label and Input
                              Text(
                                'Voter ID',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _voterIdController,
                                style: AppTypography.bodyMd,
                                keyboardType: TextInputType.number,
                                cursorColor: AppColors.primaryContainer,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black.withValues(
                                    alpha: 0.2,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.badge_outlined,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  hintText: 'Enter your 12-digit Voter ID',
                                  hintStyle: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryContainer,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: AppTypography.labelSm.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your Voter ID';
                                  }
                                  if (value.trim().length < 12) {
                                    return 'Voter ID is of 12 Digits digits';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              // Password Label and Input
                              Text(
                                'Password',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                style: AppTypography.bodyMd,
                                obscureText: _obscurePassword,
                                cursorColor: AppColors.primaryContainer,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black.withValues(
                                    alpha: 0.2,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  hintText: '••••••••',
                                  hintStyle: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryContainer,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: AppTypography.labelSm.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.trim().length < 11) {
                                    return 'Password is of 11 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24),

                              // Log In Button
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isLoading
                                      ? null
                                      : AppDecorations.primaryGlow(),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryContainer,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: AppColors
                                        .primaryContainer
                                        .withValues(alpha: 0.6),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 2.0,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Log In',
                                              style: AppTypography.headlineSm
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            SizedBox(width: 8),
                                            const Icon(
                                              Icons.login,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              // Divider

                              // Sign Up Section
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Security Footer
                    const SizedBox(height: 32),
                    const Icon(
                      Icons.lock_person_outlined,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your data is encrypted and securely stored.',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
