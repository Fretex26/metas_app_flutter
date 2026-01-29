import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/delete_sponsored_goal.use_case.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/verification_method.dart';
import 'package:metas_app/features/projects/presentation/components/delete_confirmation_dialog.dart';
import 'package:metas_app/features/sponsored_goals/presentation/pages/edit_sponsored_goal.page.dart';

/// Detalle de un objetivo patrocinado para el sponsor (ver, editar, eliminar).
class SponsorGoalDetailSponsorPage extends StatelessWidget {
  final SponsoredGoal goal;

  const SponsorGoalDetailSponsorPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Objetivo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _edit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de inicio',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            _formatDate(goal.startDate),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de fin',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            _formatDate(goal.endDate),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (goal.description != null && goal.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descripción',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(goal.description!, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
            if (goal.categories != null && goal.categories!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categorías',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: goal.categories!
                            .map((c) => Chip(label: Text(c.name)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(context, Icons.people, 'Máximo ${goal.maxUsers} usuarios'),
                    const SizedBox(height: 8),
                    _infoRow(
                      context,
                      Icons.verified_user,
                      'Verificación: ${_verificationLabel(goal.verificationMethod)}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  String _verificationLabel(VerificationMethod v) {
    switch (v) {
      case VerificationMethod.qr:
        return 'QR';
      case VerificationMethod.checklist:
        return 'Checklist';
      case VerificationMethod.manual:
        return 'Manual';
      case VerificationMethod.externalApi:
        return 'API externa';
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditSponsoredGoalPage(goal: goal),
      ),
    );
    if (!context.mounted) return;
    if (updated == true) Navigator.pop(context, true);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Eliminar objetivo patrocinado',
      message: '¿Eliminar "${goal.name}"? Esta acción no se puede deshacer.',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<DeleteSponsoredGoalUseCase>()(goal.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objetivo eliminado'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }
}
