// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peminjaman_alat/presentation/pages/admin_dashboard_page.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository_dummy.dart';
import 'data/repositories/alat_repository_dummy.dart';
import 'data/repositories/peminjaman_repository_dummy.dart';
import 'presentation/blocs/auth_cubit.dart';
import 'presentation/blocs/alat_cubit.dart';
import 'presentation/blocs/peminjaman_cubit.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/peminjam_dashboard_page.dart';
import 'presentation/pages/petugas_dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryDummy();
    final alatRepository = AlatRepositoryDummy();
    final peminjamanRepository = PeminjamanRepositoryDummy();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authRepository),
        ),
        BlocProvider(
          create: (context) => AlatCubit(alatRepository),
        ),
        BlocProvider(
          create: (context) => PeminjamanCubit(peminjamanRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Pinjamin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppNavigator(),
      ),
    );
  }
}

// Widget terpisah untuk handle navigasi
class AppNavigator extends StatelessWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Navigasi akan otomatis karena widget rebuild
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is Authenticated) {
          // Routing berdasarkan role
          switch (state.user.role) {
            case 'peminjam':
              return const PeminjamDashboardPage();
            case 'petugas':
              return const PetugasDashboardPage();
            case 'admin':
              return const AdminDashboardPage(); // Tambah ini
            default:
              return const LoginPage();
          }
        }

        // Default: Unauthenticated atau error
        return const LoginPage();
      },
    );
  }
}