import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/components/my_role_dropdown.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield_multiline.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.states.dart';
import 'package:metas_app/features/sponsor/infrastructure/dto/create_sponsor.dto.dart';

class RegisterPage extends StatefulWidget {
  final Function() togglePages;
  final String? googleEmail;
  final bool isGoogleRegistration;
  
  const RegisterPage({
    super.key, 
    required this.togglePages,
    this.googleEmail,
    this.isGoogleRegistration = false,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final nameController = TextEditingController();
  final businessNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactEmailController = TextEditingController();
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    if (widget.googleEmail != null) {
      emailController.text = widget.googleEmail!;
      contactEmailController.text = widget.googleEmail!;
    }
  }

  bool _validateSponsorFields() {
    if (businessNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre del negocio es requerido')),
      );
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descripción del negocio es requerida')),
      );
      return false;
    }
    if (contactEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de contacto es requerido')),
      );
      return false;
    }
    return true;
  }

  CreateSponsorDto? _buildSponsorDto() {
    if (selectedRole != 'sponsor') return null;
    return CreateSponsorDto(
      businessName: businessNameController.text.trim(),
      description: descriptionController.text.trim(),
      contactEmail: contactEmailController.text.trim(),
    );
  }

  Future<void> signUp() async {
    final authCubit = context.read<AuthCubit>();
    if (widget.isGoogleRegistration) {
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre es requerido')),
        );
        return;
      }
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar un propósito')),
        );
        return;
      }
      if (selectedRole == 'sponsor' && !_validateSponsorFields()) return;
      await authCubit.completeGoogleRegistration(
        nameController.text,
        selectedRole!,
        sponsorData: _buildSponsorDto(),
      );
    } else {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          passwordConfirmationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos los campos son requeridos')),
        );
        return;
      }
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar un propósito')),
        );
        return;
      }
      if (passwordController.text != passwordConfirmationController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }
      if (selectedRole == 'sponsor' && !_validateSponsorFields()) return;
      await authCubit.signUp(
        nameController.text,
        emailController.text,
        passwordController.text,
        selectedRole!,
        sponsorData: _buildSponsorDto(),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    businessNameController.dispose();
    descriptionController.dispose();
    contactEmailController.dispose();
    super.dispose();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              Icon(
                Icons.lock_open,
                size: selectedRole == 'sponsor' ? 70 : 100,
                color: Theme.of(context).colorScheme.primary,
              ),

              SizedBox(height: selectedRole == 'sponsor' ? 16 : 20),

              Text(
                widget.isGoogleRegistration 
                    ? "COMPLETA TU REGISTRO" 
                    : "CREA UNA CUENTA",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              SizedBox(height: 20),

              MyTextField(
                controller: nameController,
                hintText: 'Nombre',
                obscureText: false,
              ),

              SizedBox(height: 10),

              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
                enabled: !widget.isGoogleRegistration, // Email de solo lectura cuando viene de Google
              ),

              if (!widget.isGoogleRegistration) ...[
                SizedBox(height: 10),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  obscureText: true,
                ),

                SizedBox(height: 10),

                MyTextField(
                  controller: passwordConfirmationController,
                  hintText: 'Confirmar Contraseña',
                  obscureText: true,
                ),
              ],

              SizedBox(height: 10),

              MyRoleDropdown(
                value: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),

              if (selectedRole == 'sponsor') ...[
                SizedBox(height: 12),
                Text(
                  'Datos del negocio (patrocinador)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 6),
                MyTextField(
                  controller: businessNameController,
                  hintText: 'Nombre del negocio',
                  obscureText: false,
                ),
                SizedBox(height: 10),
                MyTextFieldMultiline(
                  controller: descriptionController,
                  hintText: 'Descripción del negocio',
                ),
                SizedBox(height: 10),
                MyTextField(
                  controller: contactEmailController,
                  hintText: 'Email de contacto',
                  obscureText: false,
                ),
                SizedBox(height: 12),
              ],

              SizedBox(height: 20),

              MyButton(
                onTap: signUp, 
                text: widget.isGoogleRegistration ? "COMPLETAR REGISTRO" : "CREAR CUENTA"
              ),

              SizedBox(height: 20),

              if (!widget.isGoogleRegistration)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¿Ya tienes una cuenta?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextButton(onPressed: () {
                      widget.togglePages();
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
      ),
    );
  }
}
