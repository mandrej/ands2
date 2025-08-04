import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/user_bloc.dart';
import '../find/cubit/find_cubit.dart';
import '../photo/bloc/photo_bloc.dart';
import '../widgets/menu.dart';
import '../widgets/alert_box.dart';
import '../widgets/find_form.dart';
import '../widgets/simple_grid_view.dart';
import '../widgets/edit_view.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.title});
  final String title;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  final Widget drawerContent = Builder(
    builder: (context) {
      return BlocProvider(
        create: (context) => UserBloc(),
        child: Column(children: [FindForm(), Spacer(), Menu()]),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth >= 600;

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: <Widget>[EditView()],
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            drawer: isLargeScreen ? null : Drawer(child: drawerContent),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLargeScreen)
                  Container(
                    width: 250,
                    color: Theme.of(context).colorScheme.surface,
                    child: drawerContent,
                  ),
                Expanded(
                  child: BlocListener<FindCubit, FindState>(
                    listener: (context, findState) {
                      // When FindCubit state changes, notify PhotoBloc
                      context.read<PhotoBloc>().add(
                        PhotoFetched(findState: findState),
                      );
                    },
                    child: BlocBuilder<PhotoBloc, PhotoState>(
                      buildWhen: (previous, current) {
                        if (previous.records.length != current.records.length) {
                          return true;
                        }
                        return false;
                      },
                      builder: (context, state) {
                        switch (state.status) {
                          case PhotoStatus.failure:
                            return const AlertBox(
                              title: 'Error',
                              content: 'Failed to fetch records.',
                            );
                          case PhotoStatus.success:
                            if (state.records.isEmpty) {
                              return const AlertBox(
                                title: 'No Records',
                                content: 'No records found. Please try again.',
                              );
                            }
                            return Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: Column(
                                      children: [
                                        SimpleGridView(records: state.records),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          case PhotoStatus.initial:
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final photoState = context.read<PhotoBloc>().state;
      final findState = context.read<FindCubit>().state;
      final lastPhoto = photoState.records.last;
      context.read<PhotoBloc>().add(
        PhotoFetched(findState: findState, fromFilename: lastPhoto.filename),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.7);
  }
}
