// lib/presentation/pages/admin/user_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/app_user.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/app_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadUsers();
  }

  Future<void> _refresh() async {
    await context.read<UserCubit>().loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger600,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _refresh,
              ),
            ),
          );
        } else if (state is UserCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${state.user.displayNameOrEmail} berhasil dibuat'),
              backgroundColor: AppColors.success600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UserUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User berhasil diupdate'),
              backgroundColor: AppColors.success600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UserDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User berhasil dihapus'),
              backgroundColor: AppColors.success600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol tambah untuk mobile (sama seperti kategori)
                if (isMobile) ...[
                  ElevatedButton.icon(
                    onPressed: () => _showCreateUserDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah User'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Content
                if (state is UserLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is UsersLoaded) ...[
                  if (state.users.isEmpty)
                    _buildEmptyState()
                  else
                    isMobile
                        ? _buildMobileList(state.users)
                        : _buildDesktopList(state.users),
                ] else if (state is UserError)
                  _buildErrorState(state.message),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopList(List<AppUser> users) {
    return AppCard(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Nama / Email', style: AppTypography.labelLarge)),
                Expanded(child: Text('Role', style: AppTypography.labelLarge)),
                SizedBox(width: 100, child: Text('Aksi', style: AppTypography.labelLarge)),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          ...users.asMap().entries.map((entry) {
            final user = entry.value;
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                    child: Text(
                      user.initials,
                      style: TextStyle(color: _getRoleColor(user.role)),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayNameOrEmail,
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (user.displayName != null)
                              Text(
                                user.email,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Chip(
                          label: Text(user.role),
                          backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                          labelStyle: TextStyle(color: _getRoleColor(user.role)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showEditDialog(context, user),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: AppColors.danger500),
                              onPressed: () => _confirmDelete(context, user),
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.key < users.length - 1) const Divider(height: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<AppUser> users) {
    return Column(
      children: users.map((user) => AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
            child: Text(
              user.initials,
              style: TextStyle(color: _getRoleColor(user.role)),
            ),
          ),
          title: Text(
            user.displayNameOrEmail,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(user.email, style: AppTypography.bodySmall),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _showEditDialog(context, user);
              if (value == 'delete') _confirmDelete(context, user);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 18, color: AppColors.danger600),
                    const SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: AppColors.danger600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.neutral300),
            const SizedBox(height: 16),
            Text('Belum ada user terdaftar', style: AppTypography.h4.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateUserDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah User'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.danger500),
            const SizedBox(height: 16),
            Text('Terjadi kesalahan', style: AppTypography.h4),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.danger600;
      case 'petugas':
        return AppColors.secondary600;
      default:
        return AppColors.info600;
    }
  }

  void _showCreateUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String selectedRole = 'peminjam';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah User Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                    DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                    DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
                  ],
                  onChanged: (v) => selectedRole = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<UserCubit>().createUser(
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  displayName: nameCtrl.text.trim(),
                  role: selectedRole,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppUser user) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.displayName ?? '');
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.email,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                  DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                  DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
                ],
                onChanged: (v) {
                  if (v != null) selectedRole = v;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<UserCubit>().updateUser(
                  user.id,
                  displayName: nameCtrl.text.trim(),
                  role: selectedRole,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User?'),
        content: Text(
          'Yakin ingin menghapus user "${user.displayNameOrEmail}"?\n\n'
          'Email: ${user.email}\n'
          'Role: ${user.role}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            onPressed: () {
              context.read<UserCubit>().deleteUser(user.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}