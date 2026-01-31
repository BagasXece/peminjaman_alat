// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peminjaman_alat/core/network/supabase_client.dart';
import 'package:peminjaman_alat/core/services/session_manager.dart';
import 'package:peminjaman_alat/data/repositories/alat_repository_supabase.dart';
import 'package:peminjaman_alat/data/repositories/auth_repository_supabase.dart';
import 'package:peminjaman_alat/data/repositories/kategori_repository_supabase.dart';
import 'package:peminjaman_alat/data/repositories/peminjaman_repository_supabase.dart';
import 'package:peminjaman_alat/data/repositories/sub_kategori_repository_supabase.dart';
import 'package:peminjaman_alat/data/repositories/user_repository_supabase.dart';
import 'package:peminjaman_alat/presentation/blocs/auth/auth_state.dart';
import 'package:peminjaman_alat/presentation/blocs/kategori/kategori_cubit.dart';
import 'package:peminjaman_alat/presentation/blocs/peminjaman/peminjaman_admin_cubit.dart';
import 'package:peminjaman_alat/presentation/blocs/sub_kategori/sub_kategori_cubit.dart';
import 'package:peminjaman_alat/presentation/pages/admin/admin_dashboard_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/blocs/alat/alat_cubit.dart';
import 'presentation/blocs/peminjaman/peminjaman_cubit.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/peminjam_dashboard_page.dart';
import 'presentation/pages/petugas_dashboard_page.dart';

// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://ewqalbtfcpntbpullukp.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3cWFsYnRmY3BudGJwdWxsdWtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjg2OTgsImV4cCI6MjA3MDc0NDY5OH0.Pg1SYw-2MJTFAXpPu8UNqDHnw47LwaDHmutZCvFwEAU",
  );

  // [PENTING] Initialize SessionManager
  await SessionManager().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supabaseClient = SupabaseService();

    final alatRepository = AlatRepositorySupabase(supabaseClient);
    final kategoriRepository = KategoriRepositorySupabase(supabaseClient);
    final subKategoriRepository = SubKategoriRepositorySupabase(supabaseClient);
    final peminjamanRepository = PeminjamanRepositorySupabase(supabaseClient);
    final authRepository = AuthRepositorySupabase(supabaseClient);
    final userRepository = UserRepositorySupabase(supabaseClient); // Buat sekali saja

    return MultiBlocProvider(
      providers: [
    BlocProvider(create: (context) => AuthCubit(authRepository)),
    BlocProvider(create: (context) => AlatCubit(alatRepository)),
    BlocProvider(create: (context) => KategoriCubit(kategoriRepository)),
    BlocProvider(create: (context) => SubKategoriCubit(subKategoriRepository)),
    // PeminjamanCubit untuk user biasa (lihat peminjamannya sendiri)
    BlocProvider(create: (context) => PeminjamanCubit(peminjamanRepository), lazy: true),
    // PeminjamanAdminCubit untuk admin/petugas (lihat semua)
    BlocProvider(
      create: (context) => PeminjamanAdminCubit(peminjamanRepository),
      lazy: true,
    ),
    BlocProvider(
      create: (context) => UserCubit(userRepository),
      lazy: true,
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
    return BlocConsumer<AuthCubit, AuthCState>(
      listener: (context, state) {
        // Navigasi akan otomatis karena widget rebuild
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
