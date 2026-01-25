// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository_dummy.dart';
import 'data/repositories/alat_repository_dummy.dart';
import 'data/repositories/peminjaman_repository_dummy.dart';
import 'presentation/blocs/auth_cubit.dart';
import 'presentation/blocs/alat_cubit.dart';
import 'presentation/blocs/peminjaman_cubit.dart';
import 'presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final authRepository = AuthRepositoryDummy();
    final alatRepository = AlatRepositoryDummy();
    final peminjamanRepository = PeminjamanRepositoryDummy();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(authRepository)..checkAuth(),
        ),
        BlocProvider(
          create: (_) => AlatCubit(alatRepository),
        ),
        BlocProvider(
          create: (_) => PeminjamanCubit(peminjamanRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Pinjamin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Always start with login for demo purposes
            // In production, check if authenticated and route accordingly
            return const LoginPage();
          },
        ),
      ),
    );
  }
}