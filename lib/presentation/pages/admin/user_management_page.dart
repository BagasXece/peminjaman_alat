// lib/presentation/pages/admin/user_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peminjaman_alat/core/theme/app_typography.dart';
import 'package:peminjaman_alat/presentation/blocs/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/app_user.dart';
import '../../widgets/app_card.dart';

class UserManagementPage extends StatelessWidget {
  final bool isEmbedded;
  
  const UserManagementPage({
    Key? key, 
    this.isEmbedded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Jika embedded (di dalam AdminDashboard), gunakan content langsung
    if (isEmbedded) {
      return _UserManagementContent(
        onAddUser: () => _showCreateUserDialog(context),
      );
    }
    
    // Jika standalone (full page), gunakan Scaffold sendiri
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen User'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<UserCubit>().loadUsers(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateUserDialog(context),
          ),
        ],
      ),
      body: _UserManagementContent(
        onAddUser: () => _showCreateUserDialog(context),
      ),
    );
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
        title: Text('Tambah User Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: passwordCtrl,
                  decoration: InputDecoration(
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
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: [
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
            child: Text('Batal'),
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
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus User?'),
        content: Text('Yakin ingin menghapus user "${user.displayNameOrEmail}"?\n\nEmail: ${user.email}\nRole: ${user.role}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            onPressed: () {
              context.read<UserCubit>().deleteUser(user.id);
              Navigator.pop(context);
            },
            child: Text('Hapus'),
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
        title: Text('Edit User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.email,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                items: [
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
            child: Text('Batal'),
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
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

// Widget terpisah untuk konten (tanpa Scaffold)
class _UserManagementContent extends StatelessWidget {
  final VoidCallback onAddUser;

  const _UserManagementContent({required this.onAddUser});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger500,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => context.read<UserCubit>().loadUsers(),
              ),
            ),
          );
        } else if (state is UserCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${state.user.displayNameOrEmail} berhasil dibuat'),
              backgroundColor: AppColors.success500,
            ),
          );
        } else if (state is UserUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User berhasil diupdate'),
              backgroundColor: AppColors.success500,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is UserLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (state is UsersLoaded) {
          if (state.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada user terdaftar'),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onAddUser,
                    icon: Icon(Icons.add),
                    label: Text('Tambah User'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              // Header untuk mobile
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manajemen User',
                      style: AppTypography.h3,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => context.read<UserCubit>().loadUsers(),
                          tooltip: 'Refresh',
                        ),
                        ElevatedButton.icon(
                          onPressed: onAddUser,
                          icon: Icon(Icons.add),
                          label: Text('Tambah'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return _UserCard(
                      user: user,
                      onDelete: () => _confirmDelete(context, user),
                      onEdit: () => _showEditDialog(context, user),
                    );
                  },
                ),
              ),
            ],
          );
        }
        
        if (state is UserError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.danger500),
                SizedBox(height: 16),
                Text('Terjadi kesalahan', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text(state.message, textAlign: TextAlign.center),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<UserCubit>().loadUsers(),
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void _confirmDelete(BuildContext context, AppUser user) {
    // Mencari UserManagementPage di widget tree
    final userManagementPage = context.findAncestorWidgetOfExactType<UserManagementPage>();
    if (userManagementPage != null) {
      userManagementPage._confirmDelete(context, user);
    }
  }

  void _showEditDialog(BuildContext context, AppUser user) {
    // Mencari UserManagementPage di widget tree
    final userManagementPage = context.findAncestorWidgetOfExactType<UserManagementPage>();
    if (userManagementPage != null) {
      userManagementPage._showEditDialog(context, user);
    }
  }
}

// Helper method untuk mengakses metode private dari luar
extension UserManagementPageExtension on UserManagementPage {
  void _confirmDelete(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus User?'),
        content: Text('Yakin ingin menghapus user "${user.displayNameOrEmail}"?\n\nEmail: ${user.email}\nRole: ${user.role}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            onPressed: () {
              context.read<UserCubit>().deleteUser(user.id);
              Navigator.pop(context);
            },
            child: Text('Hapus'),
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
        title: Text('Edit User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.email,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                items: [
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
            child: Text('Batal'),
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
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _UserCard({
    required this.user,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
          child: Text(
            user.initials,
            style: TextStyle(color: _getRoleColor(user.role)),
          ),
        ),
        title: Text(user.displayNameOrEmail),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(user.role),
              backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
              labelStyle: TextStyle(color: _getRoleColor(user.role)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
                  ),
                  onTap: onEdit,
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.danger600),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: AppColors.danger600)),
                    ],
                  ),
                  onTap: onDelete,
                ),
              ],
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
}