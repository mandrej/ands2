import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/auth/bloc/user_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'confirm_delete.dart';
import 'edit_dialog.dart';
import '../photo/models/photo.dart';

class SimpleGridView extends StatelessWidget {
  const SimpleGridView({super.key, required this.records});
  final List<Photo> records;

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width ~/ 320,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 1,
      ),
      shrinkWrap: true,
      children:
          records.map((record) {
            return ItemThumbnail(
              record: record,
              onTap: () {
                open(context, records.indexOf(record));
              },
            );
          }).toList(),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GalleryPhotoViewWrapper(
              records: records,
              initialIndex: index,
              scrollDirection: Axis.horizontal,
            ),
      ),
    );
  }
}

class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({super.key, required this.record, required this.onTap});

  final Photo record;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: record.filename,
        child: Builder(
          builder: (context) {
            // Removed EditModeCubit dependency
            final editMode =
                context
                    .watch<UserBloc>()
                    .state
                    .isEditing; // Default to non-edit mode
            return Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Column(
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(record.thumb, fit: BoxFit.cover),
                      ),
                      if (editMode)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 42,
                            alignment: Alignment.topRight,
                            child: Column(
                              children: [
                                DeleteButton(record: record),
                                EditButton(record: record),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black45),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            record.headline,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    super.key,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.records,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;

  final List<Photo> records;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final editMode = context.watch<UserBloc>().state.isEditing;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.records[currentIndex].headline),

            actions:
                (editMode)
                    ? [
                      DeleteButton(
                        record: widget.records[currentIndex],
                        color: Colors.black,
                      ),

                      EditButton(
                        record: widget.records[currentIndex],
                        color: Colors.black,
                      ),
                    ]
                    : null,
          ),
          body: Expanded(
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.records.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
          ),
        );
      },
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final record = widget.records[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(record.url),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: 1,
      heroAttributes: PhotoViewHeroAttributes(tag: record.filename),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.record,
    this.color = Colors.white,
  });
  final Photo record;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      color: color,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => DeleteDialog(record: record),
          barrierDismissible: false,
        );
      },
    );
  }
}

class EditButton extends StatelessWidget {
  const EditButton({
    super.key,
    required this.record,
    this.color = Colors.white,
  });
  final Photo record;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return IconButton(
      icon: const Icon(Icons.edit),
      color: color,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            if (width <= 600) {
              return Dialog.fullscreen(child: EditDialog(editRecord: record));
            } else {
              return EditDialog(editRecord: record);
            }
          },
          barrierDismissible: false,
        );
      },
    );
  }
}
