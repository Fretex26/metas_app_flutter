import 'package:flutter/material.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/pages/login.page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_open,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
        
              SizedBox(height: 25),
        
              Text(
                "CREA UNA CUENTA",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
        
              SizedBox(height: 25),

              MyTextField(controller: nameController, hintText: 'Nombre', obscureText: false),

              SizedBox(height: 10),
        
              MyTextField(controller: emailController, hintText: 'Email', obscureText: false),

              SizedBox(height: 10),

              MyTextField(controller: passwordController, hintText: 'Contraseña', obscureText: true),

              SizedBox(height: 10),

              MyTextField(controller: passwordConfirmationController, hintText: 'Confirmar Contraseña', obscureText: true),

              SizedBox(height: 25),

              MyButton(onTap: () {}, text: "CREAR CUENTA"),

              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("¿Ya tienes una cuenta?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextButton(onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  }, child: Text("Ingresa aquí",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}