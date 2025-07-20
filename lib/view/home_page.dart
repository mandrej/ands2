import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_infinite_list/values/bloc/available_values_bloc.dart';
import 'package:flutter_infinite_list/photo/cubit/last_photo_cubit.dart';
import 'package:flutter_infinite_list/photo/cubit/first_photo_cubit.dart';
import 'package:flutter_infinite_list/auth/bloc/user_bloc.dart';
import 'package:flutter_infinite_list/helpers/common.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AvailableValuesBloc>(
          create:
              (context) => AvailableValuesBloc()..add(FetchAvailableValues()),
        ),
        BlocProvider(create: (context) => LastRecordCubit()..fetchLastRecord()),
        BlocProvider(
          create: (context) => FirstRecordCubit()..fetchFirstRecord(),
        ),
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
      ],
      child: BlocBuilder<AvailableValuesBloc, AvailableValuesState>(
        builder: (context, availableValuesState) {
          final double screenWidth = MediaQuery.of(context).size.width;
          final double screenHeight = MediaQuery.of(context).size.height;
          final bool valuesAvailable = availableValuesState.email != null;
          final userState = context.read<UserBloc>().state;
          final bool userSignedIn = userState is UserAuthenticated;

          return Scaffold(
            body: Center(
              child:
                  valuesAvailable
                      ? (screenWidth < 960
                          ? Column(
                            children: [
                              FrontButton(
                                width: screenWidth,
                                height: screenHeight / 2,
                              ),
                              FronTitle(
                                title: title,
                                width: screenWidth,
                                height: screenHeight / 2,
                              ),
                            ],
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FrontButton(
                                width: screenWidth / 2,
                                height: screenHeight,
                              ),
                              FronTitle(
                                title: title,
                                width: screenWidth / 2,
                                height: screenHeight,
                              ),
                            ],
                          ))
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/camera.svg',
                            width: 100,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).primaryColor,
                              BlendMode.srcIn,
                            ),
                            semanticsLabel: 'App Logo',
                          ),
                          Text(
                            title,
                            style: TextStyle(fontSize: 40),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No images yet\n Sign in with Google\n to add some',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (!userSignedIn)
                            FilledButton(
                              onPressed: () async {
                                context.read<UserBloc>().add(
                                  UserSignInRequested(),
                                );
                              },
                              child: Text('Sign in'),
                            )
                          else
                            IconButton(
                              onPressed:
                                  () => Navigator.pushNamed(context, '/add'),
                              icon: Icon(Icons.add),
                              style: IconButton.styleFrom(
                                iconSize: 40.0,
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                        ],
                      ),
            ),
          );
        },
      ),
    );
  }
}

class FrontButton extends StatelessWidget {
  const FrontButton({super.key, required this.width, required this.height});
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: BlocBuilder<LastRecordCubit, LastRecordState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/list'),
            style: ElevatedButton.styleFrom(
              elevation: 16,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child:
                state is! LastRecordLoaded
                    ? SizedBox(
                      width: width,
                      height: height,
                      child: SvgPicture.asset(
                        'assets/camera.svg',
                        width: 100,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).secondaryHeaderColor,
                          BlendMode.srcIn,
                        ),
                        semanticsLabel: 'App Logo',
                      ),
                    )
                    : Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage((state).photo.url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }
}

class FronTitle extends StatelessWidget {
  const FronTitle({
    super.key,
    required this.title,
    required this.width,
    required this.height,
  });
  final String title;
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 40)),
            BlocBuilder<FirstRecordCubit, FirstRecordState>(
              builder: (context, state) {
                return state is FirstRecordLoaded
                    ? Text(
                      'Since ${state.photo.year.toString()}',
                      style: TextStyle(fontSize: 14),
                    )
                    : Text('waiting');
              },
            ),
            SizedBox(height: 16.0),
            BlocConsumer<UserBloc, UserState>(
              listener: (context, state) {},
              builder: (context, auth) {
                if (auth is UserAuthenticated) {
                  return Column(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/add'),
                        icon: Icon(Icons.add),
                        style: IconButton.styleFrom(
                          iconSize: 40.0,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      BlocBuilder<AvailableValuesBloc, AvailableValuesState>(
                        builder: (context, values) {
                          if (values.email != null &&
                              values.email is Map<String, int>) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  (values.email as Map<String, int>).keys
                                      .map<Widget>((email) {
                                        return Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Text(
                                            nickEmail(email),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.headlineSmall,
                                          ),
                                        );
                                      })
                                      .toList(),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<UserBloc>().add(UserSignOutRequested());
                        },
                        child: Text('Sign out ${auth.user.displayName}'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () {
                          context.read<UserBloc>().add(UserSignInRequested());
                        },
                        child: Text('Sign in with Google'),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
