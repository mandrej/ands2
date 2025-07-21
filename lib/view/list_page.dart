import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../find/cubit/find_cubit.dart';
import '../photo/bloc/photo_bloc.dart';
import '../widgets/bottom_loader.dart';
import '../widgets/post_list_item.dart';
import '../widgets/find_form.dart';

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
      return Column(
        children: [
          FindForm(),
          // EditView(),
          Spacer(),
          _SidebarItem(
            icon: Icons.home,
            label: 'Home',
            onTap: () => Navigator.pushNamed(context, '/'),
          ),
          _SidebarItem(
            icon: Icons.add,
            label: 'Add',
            onTap: () => Navigator.pushNamed(context, '/add'),
          ),
          _SidebarItem(
            icon: Icons.settings,
            label: 'Admin',
            onTap: () => Navigator.pushNamed(context, '/admin'),
          ),
          SizedBox(height: 8.0),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FindCubit>(
      create: (context) => FindCubit(),
      child: BlocProvider<PhotoBloc>(
        create:
            (context) =>
                PhotoBloc(context.read<FindCubit>())..add(PhotoFetched()),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isLargeScreen = constraints.maxWidth >= 600;

            return Scaffold(
              appBar: AppBar(title: Text(widget.title)),
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
                    child: BlocBuilder<PhotoBloc, PhotoState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case PhotoStatus.failure:
                            return const Center(
                              child: Text('failed to fetch records'),
                            );
                          case PhotoStatus.success:
                            if (state.records.isEmpty) {
                              return const Center(child: Text('no records'));
                            }
                            return ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return index >= state.records.length
                                    ? const BottomLoader()
                                    : PostListItem(photo: state.records[index]);
                              },
                              itemCount:
                                  state.hasReachedMax
                                      ? state.records.length
                                      : state.records.length + 1,
                              controller: _scrollController,
                            );
                          case PhotoStatus.initial:
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<PhotoBloc>().add(PhotoFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
      onTap: onTap,
      // dense: true,
    );
  }
}
