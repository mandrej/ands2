import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'route_guards.dart';
import 'auth/bloc/user_bloc.dart';
import 'photo/bloc/photo_bloc.dart';
import 'find/cubit/find_cubit.dart';
import 'photo/bloc/uploadphoto_bloc.dart';
import 'view/home_page.dart';
import 'view/list_page.dart';
// import 'view/add_page.dart';
import 'view/upload_page.dart';
import 'view/error_page.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
    NamedRouteDef(
      name: 'Home',
      path: '/',
      initial: true,
      builder: (context, data) {
        return HomePage(title: 'Andrejeвићи');
      },
    ),
    NamedRouteDef(
      name: 'List',
      path: '/list', // optional
      builder: (context, data) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => FindCubit()),
            BlocProvider(create: (context) => UserBloc()),
          ],
          child: BlocProvider(
            create:
                (context) =>
                    PhotoBloc()..add(
                      PhotoFetched(findState: context.read<FindCubit>().state),
                    ),
            child: ListPage(),
          ),
        );
      },
    ),
    NamedRouteDef(
      name: 'Add',
      path: '/add', // optional
      builder: (context, data) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => UploadphotoBloc()),
            BlocProvider(create: (context) => UserBloc()),
          ],
          child: UploadGridPage(),
        );
      },
      guards: [AuthGuard()],
    ),
    NamedRouteDef(
      name: 'Error',
      path: '/error/:id',
      builder: (context, data) {
        return ErrorPage(title: 'Error', id: data.params.getInt('id'));
      },
    ),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
