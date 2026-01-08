import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/google_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.states.dart';

class LoginPage extends StatefulWidget {
  final Function() togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late final authCubit = context.read<AuthCubit>();

  Future<void> signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos los campos son requeridos')),
      );
      return;
    }

    await authCubit.signInWithEmailAndPassword(
      emailController.text,
      passwordController.text,
    );
  }

  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recuperar Contraseña'),
        content: MyTextField(
          controller: emailController,
          hintText: 'Email',
          obscureText: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final result = await authCubit.sendPasswordResetEmail(emailController.text);
              if (result.contains('Password reset email sent')) {
                Navigator.pop(context);
                emailController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Email de recuperación enviado')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              }
            },
            child: Text('Recuperar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.lock_open,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          
                  SizedBox(height: 25),
          
                  Text(
                    "ACCEDE A TUS PROYECTOS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          
                  SizedBox(height: 25),
          
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
          
                  SizedBox(height: 10),
          
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Contraseña',
                    obscureText: true,
                  ),
          
                  SizedBox(height: 10),
          
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: openForgotPasswordBox,
                        child: Text(
                          '¿Olvidaste la Contraseña?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
          
                  SizedBox(height: 25),
          
                  MyButton(onTap: signIn, text: "INICIAR SESIÓN"),
          
                  SizedBox(height: 25),
          
                  Text(
                    "O INGRESA CON",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          
                  SizedBox(height: 25),
          
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GoogleButton(onTap: () {
                        authCubit.signInWithGoogle();
                      }),
                    ],
                  ),
          
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿No tienes una cuenta?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.togglePages();
                        },
                        child: Text(
                          "Registrate",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
          
                  SizedBox(height: 25),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
