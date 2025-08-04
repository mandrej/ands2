import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/bloc/user_bloc.dart';
import 'find/cubit/find_cubit.dart';
import 'photo/bloc/photo_bloc.dart';
import 'task/cubit/upload_task_cubit.dart';
import 'photo/cubit/uploaded_cubit.dart';
import 'view/home_page.dart';
import 'view/list_page.dart';
import 'view/add_page.dart';
import 'theme.dart';
// import 'examples/auto_suggest_multi_field_example.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(title: 'Andrejeвићи'),
        '/list':
            (context) => BlocProvider<FindCubit>(
              create: (context) => FindCubit(),
              child: BlocProvider<PhotoBloc>(
                create:
                    (context) =>
                        PhotoBloc()..add(
                          PhotoFetched(
                            findState: context.read<FindCubit>().state,
                          ),
                        ),
                child: ListPage(title: 'Andrejeвићи'),
              ),
            ),
        '/add':
            (context) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => UserBloc()),
                BlocProvider<UploadTaskCubit>(
                  create: (context) => UploadTaskCubit(),
                ),
                BlocProvider<UploadedCubit>(
                  create: (context) => UploadedCubit(),
                ),
              ],
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return state is UserAuthenticated && state.isFamily
                      ? const AddPage()
                      : HomePage(title: 'Error');
                },
              ),
            ),
        // '/examples/auto_suggest_multi_field':
      },
    );
  }
}
