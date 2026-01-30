import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peminjaman_alat/presentation/blocs/auth/auth_cubit.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final Widget? fallback;

  const RoleGuard({
    Key? key,
    required this.child,
    required this.allowedRoles,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthCState>(
      builder: (context, state) {
        if (state is Authenticated) {
          if (allowedRoles.contains(state.user.role)) {
            return child;
          }
          return fallback ?? _buildUnauthorized();
        }
        return _buildLoginRequired();
      },
    );
  }

  Widget _buildUnauthorized() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Akses Ditolak',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Anda tidak memiliki izin untuk mengakses halaman ini'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Scaffold(
      body: Center(
        child: Text('Silakan login terlebih dahulu'),
      ),
    );
  }
}