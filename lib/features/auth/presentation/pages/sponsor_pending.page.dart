import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/my_button.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';

/// Pantalla mostrada a sponsors con [status == PENDING].
///
/// Solo acceso a ver estado; no se permite usar el portal hasta aprobación.
class SponsorPendingPage extends StatelessWidget {
  const SponsorPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 24),
                Text(
                  'En espera de aprobación',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu solicitud como patrocinador está siendo revisada por un administrador. '
                  'Podrás crear proyectos y publicar objetivos patrocinados una vez aprobada.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                MyButton(
                  onTap: () => context.read<AuthCubit>().signOut(),
                  text: 'CERRAR SESIÓN',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
