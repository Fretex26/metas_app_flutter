import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/admin/application/use_cases/admin_sponsors.use_cases.dart';
import 'package:metas_app/features/admin/domain/entities/admin_sponsor.dart';
import 'package:metas_app/features/admin/presentation/cubits/admin_sponsors.cubit.dart';
import 'package:metas_app/features/admin/presentation/cubits/admin_sponsors.states.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';

/// Portal admin: listar sponsors pendientes y todos, aprobar, rechazar, deshabilitar, habilitar.
class AdminSponsorsPage extends StatelessWidget {
  const AdminSponsorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminSponsorsCubit(
        getPending: context.read<GetAdminPendingSponsorsUseCase>(),
        getAll: context.read<GetAdminAllSponsorsUseCase>(),
        approveUseCase: context.read<AdminApproveSponsorUseCase>(),
        rejectUseCase: context.read<AdminRejectSponsorUseCase>(),
        disableUseCase: context.read<AdminDisableSponsorUseCase>(),
        enableUseCase: context.read<AdminEnableSponsorUseCase>(),
      )..load(),
      child: BlocConsumer<AdminSponsorsCubit, AdminSponsorsState>(
        listener: (context, state) {
          if (state is AdminSponsorsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is AdminSponsorsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Gestión de sponsors'),
              actions: [
                IconButton(
                  onPressed: () => context.read<AuthCubit>().signOut(),
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminSponsorsState state) {
    if (state is AdminSponsorsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AdminSponsorsLoaded) {
      return RefreshIndicator(
        onRefresh: () => context.read<AdminSponsorsCubit>().load(
              status: state.filterStatus,
            ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPendingSection(context, state.pending),
              const SizedBox(height: 24),
              _buildAllSection(context, state),
            ],
          ),
        ),
      );
    }
    if (state is AdminSponsorsError) {
      final isForbidden = state.message.toLowerCase().contains('no tienes permisos') ||
          state.message.toLowerCase().contains('forbidden') ||
          state.message.toLowerCase().contains('403');
      final isUnauthorized = state.message.toLowerCase().contains('sesión ha expirado') ||
          state.message.toLowerCase().contains('no autenticado') ||
          state.message.toLowerCase().contains('401');
      
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isForbidden || isUnauthorized
                    ? Icons.block_outlined
                    : Icons.error_outline,
                size: 64,
                color: isForbidden || isUnauthorized
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                isForbidden
                    ? 'Acceso denegado'
                    : isUnauthorized
                        ? 'Error de autenticación'
                        : 'Error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),
              if (!isForbidden && !isUnauthorized)
                ElevatedButton(
                  onPressed: () => context.read<AdminSponsorsCubit>().load(),
                  child: const Text('Reintentar'),
                )
              else
                ElevatedButton(
                  onPressed: () => context.read<AuthCubit>().signOut(),
                  child: const Text('Cerrar sesión'),
                ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPendingSection(BuildContext context, List<AdminSponsor> pending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pendientes de aprobación',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No hay sponsors pendientes',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          )
        else
          ...pending.map((s) => _SponsorCard(s: s, showPendingActions: true)),
      ],
    );
  }

  Widget _buildAllSection(BuildContext context, AdminSponsorsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Todos los sponsors',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String?>(
              value: state.filterStatus,
              hint: const Text('Estado'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                DropdownMenuItem(value: 'approved', child: Text('Aprobados')),
                DropdownMenuItem(value: 'rejected', child: Text('Rechazados')),
                DropdownMenuItem(value: 'disabled', child: Text('Deshabilitados')),
              ],
              onChanged: (v) => context.read<AdminSponsorsCubit>().load(status: v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.all.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No hay sponsors',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          )
        else
          ...state.all.map((s) => _SponsorCard(s: s, showPendingActions: false)),
      ],
    );
  }
}

class _SponsorCard extends StatelessWidget {
  final AdminSponsor s;
  final bool showPendingActions;

  const _SponsorCard({
    required this.s,
    required this.showPendingActions,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminSponsorsCubit>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.businessName ?? 'Sin nombre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _StatusChip(status: s.status),
              ],
            ),
            if (s.userName != null || s.userEmail != null) ...[
              const SizedBox(height: 8),
              Text(
                '${s.userName ?? ''} · ${s.userEmail ?? ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (s.description != null && s.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                s.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (showPendingActions && s.status == 'pending') ...[
                  FilledButton.tonal(
                    onPressed: () => cubit.approve(s),
                    child: const Text('Aprobar'),
                  ),
                  OutlinedButton(
                    onPressed: () => _showRejectDialog(context, s, cubit),
                    child: const Text('Rechazar'),
                  ),
                ],
                if (!showPendingActions) ...[
                  if (s.status == 'pending') ...[
                    FilledButton.tonal(
                      onPressed: () => cubit.approve(s),
                      child: const Text('Aprobar'),
                    ),
                    OutlinedButton(
                      onPressed: () => _showRejectDialog(context, s, cubit),
                      child: const Text('Rechazar'),
                    ),
                  ],
                  if (s.status == 'approved')
                    OutlinedButton(
                      onPressed: () => cubit.disable(s),
                      child: const Text('Deshabilitar'),
                    ),
                  if (s.status == 'disabled')
                    FilledButton.tonal(
                      onPressed: () => cubit.enable(s),
                      child: const Text('Habilitar'),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdminSponsor s, AdminSponsorsCubit cubit) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar sponsor'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Motivo (opcional)',
            hintText: 'Indica el motivo del rechazo',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.reject(s, reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim());
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'disabled':
        color = Colors.grey;
        break;
      default:
        color = Theme.of(context).colorScheme.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
