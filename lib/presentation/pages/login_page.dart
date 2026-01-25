// lib/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../blocs/auth_cubit.dart';
import 'peminjam_dashboard_page.dart';
import 'petugas_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isPasswordVisible = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'id': AppConstants.rolePeminjam,
      'label': 'Peminjam',
      'icon': Icons.school_outlined,
      'color': AppColors.info500,
      'description': 'Mahasiswa/Siswa',
    },
    {
      'id': AppConstants.rolePetugas,
      'label': 'Petugas',
      'icon': Icons.badge_outlined,
      'color': AppColors.secondary600,
      'description': 'Staff Laboratorium',
    },
    {
      'id': AppConstants.roleAdmin,
      'label': 'Admin',
      'icon': Icons.admin_panel_settings_outlined,
      'color': AppColors.primary600,
      'description': 'Administrator Sistem',
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih role terlebih dahulu'),
          backgroundColor: AppColors.danger500,
        ),
      );
      return;
    }

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan email'),
          backgroundColor: AppColors.danger500,
        ),
      );
      return;
    }

    context.read<AuthCubit>().login(
          _emailController.text,
          _passwordController.text,
          _selectedRole!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigate based on role
            if (state.user.role == AppConstants.rolePeminjam) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PeminjamDashboardPage()),
              );
            } else if (state.user.role == AppConstants.rolePetugas ||
                state.user.role == AppConstants.roleAdmin) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PetugasDashboardPage()),
              );
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger500,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary900,
                  AppColors.primary700,
                  AppColors.primary600,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo & Brand
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.build_circle_outlined,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppConstants.appName,
                          style: AppTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sistem Peminjaman Alat Permesinan',
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Role Selection
                        Text(
                          'Pilih Role',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: _roles.map((role) {
                            final isSelected = _selectedRole == role['id'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = role['id'];
                                  // Auto-fill email untuk demo
                                  if (role['id'] == AppConstants.rolePeminjam) {
                                    _emailController.text = 'mahasiswa1@student.ac.id';
                                  } else if (role['id'] == AppConstants.rolePetugas) {
                                    _emailController.text = 'petugas1@mesin.ac.id';
                                  } else {
                                    _emailController.text = 'admin@mesin.ac.id';
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: 100,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? role['color']
                                        : Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      role['icon'],
                                      color: isSelected
                                          ? role['color']
                                          : Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      role['label'],
                                      style: AppTypography.labelLarge.copyWith(
                                        color: isSelected
                                            ? AppColors.neutral900
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      role['description'],
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isSelected
                                            ? AppColors.neutral600
                                            : Colors.white.withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // Login Form
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Masuk',
                                style: AppTypography.h3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gunakan akun yang sudah terdaftar',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Email Field
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'nama@email.com',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Password Field
                              TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: '••••••••',
                                  prefixIcon: Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Hint text
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.info50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.info200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: AppColors.info600,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Untuk demo: Password apapun diterima',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.info700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Login Button
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: state is AuthLoading ? null : _login,
                                  child: state is AuthLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text('Masuk'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Footer
                        Text(
                          '© 2024 Jurusan Permesinan',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}