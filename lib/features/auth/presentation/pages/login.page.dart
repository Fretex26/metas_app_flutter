import 'package:flutter/material.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/pages/register.page.dart';

class LoginPage extends StatefulWidget {
  final Function() togglePages;
  const LoginPage({super.key, required this.togglePages });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
                "ACCEDE A TUS PROYECTOS",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
        
              SizedBox(height: 25),
        
              MyTextField(controller: emailController, hintText: 'Email', obscureText: false),

              SizedBox(height: 10),

              MyTextField(controller: passwordController, hintText: 'Contraseña', obscureText: true),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '¿Olvidaste la Contraseña?', 
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25),

              MyButton(onTap: () {}, text: "INICIAR SESIÓN"),

              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("¿No tienes una cuenta?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // TextButton(onPressed: () {
                  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                  // }, child: Text("Registrate",
                  //   style: TextStyle(
                  //     color: Theme.of(context).colorScheme.primary,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // )),
                  TextButton(onPressed: () {
                    widget.togglePages();
                  }, child: Text("Registrate",
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