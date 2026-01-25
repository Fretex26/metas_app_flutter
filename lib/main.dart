import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/infrastructure/repositories_impl/firebase_auth.repositoryImpl.dart';
import 'package:metas_app/features/auth/presentation/components/loding.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.states.dart';
import 'package:metas_app/features/auth/presentation/pages/auth.page.dart';
import 'package:metas_app/features/auth/presentation/pages/register.page.dart';
import 'package:metas_app/features/projects/application/use_cases/create_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/create_milestone.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/create_project.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/create_task.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_checklist_items.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_tasks.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_milestones.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_progress.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_task_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_projects.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_rewards.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_reward_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_by_reward_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_project.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_project.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_milestone.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_milestone.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/update_task.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_task.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/delete_checklist_item.use_case.dart';
import 'package:metas_app/features/projects/domain/repositories/checklist_item.repository.dart';
import 'package:metas_app/features/projects/domain/repositories/milestone.repository.dart';
import 'package:metas_app/features/projects/domain/repositories/project.repository.dart';
import 'package:metas_app/features/projects/domain/repositories/reward.repository.dart';
import 'package:metas_app/features/projects/domain/repositories/task.repository.dart';
import 'package:metas_app/features/projects/infrastructure/repositories_impl/checklist_item.repository_impl.dart';
import 'package:metas_app/features/projects/infrastructure/repositories_impl/milestone.repository_impl.dart';
import 'package:metas_app/features/projects/infrastructure/repositories_impl/project.repository_impl.dart';
import 'package:metas_app/features/projects/infrastructure/repositories_impl/reward.repository_impl.dart';
import 'package:metas_app/features/projects/infrastructure/repositories_impl/task.repository_impl.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_milestone.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_project.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_task.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/projects.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/rewards.cubit.dart';
import 'package:metas_app/features/projects/presentation/pages/main_navigation.page.dart';
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

  // Repositories
  final ProjectRepository _projectRepository = ProjectRepositoryImpl();
  final MilestoneRepository _milestoneRepository = MilestoneRepositoryImpl();
  final TaskRepository _taskRepository = TaskRepositoryImpl();
  final ChecklistItemRepository _checklistItemRepository = ChecklistItemRepositoryImpl();
  final RewardRepository _rewardRepository = RewardRepositoryImpl();

  // Use Cases
  GetUserProjectsUseCase get _getUserProjectsUseCase => GetUserProjectsUseCase(_projectRepository);
  GetProjectByIdUseCase get _getProjectByIdUseCase => GetProjectByIdUseCase(_projectRepository);
  GetProjectByRewardIdUseCase get _getProjectByRewardIdUseCase => GetProjectByRewardIdUseCase(_projectRepository);
  GetProjectProgressUseCase get _getProjectProgressUseCase => GetProjectProgressUseCase(_projectRepository);
  CreateProjectUseCase get _createProjectUseCase => CreateProjectUseCase(_projectRepository);
  GetProjectMilestonesUseCase get _getProjectMilestonesUseCase => GetProjectMilestonesUseCase(_milestoneRepository);
  GetMilestoneByIdUseCase get _getMilestoneByIdUseCase => GetMilestoneByIdUseCase(_milestoneRepository);
  CreateMilestoneUseCase get _createMilestoneUseCase => CreateMilestoneUseCase(_milestoneRepository);
  GetMilestoneTasksUseCase get _getMilestoneTasksUseCase => GetMilestoneTasksUseCase(_taskRepository);
  GetTaskByIdUseCase get _getTaskByIdUseCase => GetTaskByIdUseCase(_taskRepository);
  CreateTaskUseCase get _createTaskUseCase => CreateTaskUseCase(_taskRepository);
  GetChecklistItemsUseCase get _getChecklistItemsUseCase => GetChecklistItemsUseCase(_checklistItemRepository);
  CreateChecklistItemUseCase get _createChecklistItemUseCase => CreateChecklistItemUseCase(_checklistItemRepository);
  UpdateChecklistItemUseCase get _updateChecklistItemUseCase => UpdateChecklistItemUseCase(_checklistItemRepository);
  DeleteChecklistItemUseCase get _deleteChecklistItemUseCase => DeleteChecklistItemUseCase(_checklistItemRepository);
  // Rewards
  GetRewardByIdUseCase get _getRewardByIdUseCase => GetRewardByIdUseCase(_rewardRepository);
  GetUserRewardsUseCase get _getUserRewardsUseCase => GetUserRewardsUseCase(_rewardRepository);
  // Project update and delete
  UpdateProjectUseCase get _updateProjectUseCase => UpdateProjectUseCase(_projectRepository);
  DeleteProjectUseCase get _deleteProjectUseCase => DeleteProjectUseCase(_projectRepository);
  // Milestone update and delete
  UpdateMilestoneUseCase get _updateMilestoneUseCase => UpdateMilestoneUseCase(_milestoneRepository);
  DeleteMilestoneUseCase get _deleteMilestoneUseCase => DeleteMilestoneUseCase(_milestoneRepository);
  // Task update and delete
  UpdateTaskUseCase get _updateTaskUseCase => UpdateTaskUseCase(_taskRepository);
  DeleteTaskUseCase get _deleteTaskUseCase => DeleteTaskUseCase(_taskRepository);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Provide all use cases that are needed by pages using context.read()
        RepositoryProvider<GetUserProjectsUseCase>.value(
          value: _getUserProjectsUseCase,
        ),
        RepositoryProvider<GetProjectByIdUseCase>.value(
          value: _getProjectByIdUseCase,
        ),
        RepositoryProvider<GetProjectByRewardIdUseCase>.value(
          value: _getProjectByRewardIdUseCase,
        ),
        RepositoryProvider<GetProjectProgressUseCase>.value(
          value: _getProjectProgressUseCase,
        ),
        RepositoryProvider<CreateProjectUseCase>.value(
          value: _createProjectUseCase,
        ),
        RepositoryProvider<GetProjectMilestonesUseCase>.value(
          value: _getProjectMilestonesUseCase,
        ),
        RepositoryProvider<GetMilestoneByIdUseCase>.value(
          value: _getMilestoneByIdUseCase,
        ),
        RepositoryProvider<CreateMilestoneUseCase>.value(
          value: _createMilestoneUseCase,
        ),
        RepositoryProvider<GetMilestoneTasksUseCase>.value(
          value: _getMilestoneTasksUseCase,
        ),
        RepositoryProvider<GetTaskByIdUseCase>.value(
          value: _getTaskByIdUseCase,
        ),
        RepositoryProvider<CreateTaskUseCase>.value(
          value: _createTaskUseCase,
        ),
        RepositoryProvider<GetChecklistItemsUseCase>.value(
          value: _getChecklistItemsUseCase,
        ),
        RepositoryProvider<CreateChecklistItemUseCase>.value(
          value: _createChecklistItemUseCase,
        ),
        RepositoryProvider<UpdateChecklistItemUseCase>.value(
          value: _updateChecklistItemUseCase,
        ),
        RepositoryProvider<DeleteChecklistItemUseCase>.value(
          value: _deleteChecklistItemUseCase,
        ),
        // Rewards
        RepositoryProvider<GetRewardByIdUseCase>.value(
          value: _getRewardByIdUseCase,
        ),
        RepositoryProvider<GetUserRewardsUseCase>.value(
          value: _getUserRewardsUseCase,
        ),
        // Project update and delete
        RepositoryProvider<UpdateProjectUseCase>.value(
          value: _updateProjectUseCase,
        ),
        RepositoryProvider<DeleteProjectUseCase>.value(
          value: _deleteProjectUseCase,
        ),
        // Milestone update and delete
        RepositoryProvider<UpdateMilestoneUseCase>.value(
          value: _updateMilestoneUseCase,
        ),
        RepositoryProvider<DeleteMilestoneUseCase>.value(
          value: _deleteMilestoneUseCase,
        ),
        // Task update and delete
        RepositoryProvider<UpdateTaskUseCase>.value(
          value: _updateTaskUseCase,
        ),
        RepositoryProvider<DeleteTaskUseCase>.value(
          value: _deleteTaskUseCase,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authRepository: firebaseAuthRepository)..checkAuthStatus(),
          ),
          // Projects
          BlocProvider<ProjectsCubit>(
            create: (context) => ProjectsCubit(
              getUserProjectsUseCase: _getUserProjectsUseCase,
              getProjectProgressUseCase: _getProjectProgressUseCase,
            ),
          ),
          BlocProvider<CreateProjectCubit>(
            create: (context) => CreateProjectCubit(createProjectUseCase: _createProjectUseCase),
          ),
          // ProjectDetailCubit is now created per-page, not globally
          BlocProvider<CreateMilestoneCubit>(
            create: (context) => CreateMilestoneCubit(createMilestoneUseCase: _createMilestoneUseCase),
          ),
          // MilestoneDetailCubit is now created per-page, not globally
          BlocProvider<CreateTaskCubit>(
            create: (context) => CreateTaskCubit(createTaskUseCase: _createTaskUseCase),
          ),
          // TaskDetailCubit is now created per-page, not globally
          // ChecklistCubit is now created per-page, not globally
          // Rewards
          BlocProvider<RewardsCubit>(
            create: (context) => RewardsCubit(
              getRewardByIdUseCase: _getRewardByIdUseCase,
              getUserRewardsUseCase: _getUserRewardsUseCase,
            ),
          ),
        ],
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        home: BlocConsumer<AuthCubit, AuthStates>(
          builder: (context, state) {
            if (state is Unauthenticated) {
              return const AuthPage();
            }
            if (state is AuthSuccess) {
              return const MainNavigationPage();
            }
            if (state is GoogleAuthPendingRegistration) {
              return RegisterPage(
                togglePages: () {},
                googleEmail: state.email,
                isGoogleRegistration: true,
              );
            }
            return LoadingWidget();
          },
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
        ),
      ),
    ),
    );
  }
}
