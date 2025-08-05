import '../auth/bloc/user_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final auth = resolver.context.read<UserBloc>().state;
    // the navigation is paused until resolver.next() is called with either
    // true to resume/continue navigation or false to abort navigation
    if (auth is UserAuthenticated && auth.isFamily) {
      // if user is authenticated we continue
      resolver.next(true);
    } else {
      // we abort the navigation for unauthenticated users
      // they can manually navigate to the home page to sign in
      resolver.next(false);
    }
  }
}
