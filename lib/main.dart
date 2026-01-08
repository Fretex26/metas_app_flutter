import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/infrastructure/repository_Impl/firebase_auth.repositoryImpl.dart';
import 'package:metas_app/features/auth/presentation/components/loding.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.states.dart';
import 'package:metas_app/features/auth/presentation/pages/auth.page.dart';
import 'package:metas_app/features/home/presentation/pages/home.page.dart';
import 'package:metas_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:metas_app/themes/dark.mode.dart';
import 'package:metas_app/themes/light.mode.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepository = FirebaseAuthRepositoryImpl();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepository: firebaseAuthRepository)..checkAuthStatus(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        // home: const HomePage(),
        home: BlocConsumer<AuthCubit, AuthStates>(
          builder: (context, state) {
            if (state is Unauthenticated) {
              return const AuthPage();
            }
            if (state is AuthSuccess) {
              return const HomePage();
            }
            return LoadingWidget();
          }, listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
        ),
      ),
    );
  }
}
