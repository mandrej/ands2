import 'dart:async';
import 'dart:io' as io;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../task/cubit/upload_task_cubit.dart';
import '../photo/cubit/uploaded_cubit.dart';
import '../auth/bloc/user_bloc.dart';
import '../photo/models/photo.dart';
import '../helpers/read_exif.dart';
import '../helpers/common.dart';
import '../widgets/edit_dialog.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final ImagePicker _picker = ImagePicker();
  final Set<String> _processingTasks = <String>{};

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty && mounted) {
        for (final image in images) {
          final uploadTask = await uploadFile(image);
          if (uploadTask != null && mounted) {
            context.read<UploadTaskCubit>().add(uploadTask);
          }
        }
      }
    } catch (e) {
      print('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null && mounted) {
        final uploadTask = await uploadFile(image);
        if (uploadTask != null && mounted) {
          context.read<UploadTaskCubit>().add(uploadTask);
        }
      }
    } catch (e) {
      print('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  void _editPhoto(Photo photo) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditDialog(editRecord: photo)),
    );
  }

  Future<void> _handleUploadCompletion(UploadTask task, String email) async {
    final taskId = task.snapshot.ref.name;

    // Prevent duplicate processing
    if (_processingTasks.contains(taskId)) {
      print('Task $taskId already being processed, skipping');
      return;
    }

    _processingTasks.add(taskId);

    try {
      print('Processing upload completion for: $taskId');

      // Create photo record
      final photo = await _uploadedPhotoDefault(task.snapshot.ref, email);

      if (!mounted) return;

      if (!context.read<UploadedCubit>().contains(photo)) {
        context.read<UploadedCubit>().addUploaded(photo);
        print('Photo added successfully: ${photo.filename}');
      } else {
        print('Photo already exists in UploadedCubit: ${photo.filename}');
      }

      await Future.delayed(const Duration(milliseconds: 50));

      if (mounted) {
        context.read<UploadTaskCubit>().remove(task);
        print('Upload task removed successfully: $taskId');
      }
    } catch (error) {
      print('Error processing upload completion: $error');
      if (mounted) {
        context.read<UploadTaskCubit>().remove(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing photo: $error')),
        );
      }
    } finally {
      _processingTasks.remove(taskId);
    }
  }

  void _deleteUploadedPhoto(Photo photo) {
    context.read<UploadedCubit>().removeUploaded(photo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo "${photo.headline}" deleted')),
    );
  }

  @override
  void dispose() {
    _processingTasks.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Upload buttons section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick Images'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Upload tasks section
          BlocBuilder<UploadTaskCubit, UploadTaskState>(
            builder: (context, uploadState) {
              if (uploadState is UploadTaskLoaded && uploadState.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uploading (${uploadState.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...uploadState.tasks.map(
                        (task) => UploadTaskListTile(
                          task: task,
                          onUploadComplete: _handleUploadCompletion,
                          onDelete: () {
                            task.cancel();
                            context.read<UploadTaskCubit>().remove(task);
                          },
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Uploaded images grid section
          Expanded(
            child: BlocBuilder<UploadedCubit, UploadedState>(
              builder: (context, uploadedState) {
                if (uploadedState is UploadedLoaded &&
                    uploadedState.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Uploaded Images (${uploadedState.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width ~/ 320,
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                                childAspectRatio: 1,
                              ),
                          itemCount: uploadedState.length,
                          itemBuilder: (context, index) {
                            final photo = uploadedState[index];
                            return ItemThumbnail(
                              uploadedRecord: photo.toMap(),
                              onDelete: () => _deleteUploadedPhoto(photo),
                              onEdit: () => _editPhoto(photo),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No images uploaded yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the buttons above to add photos',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<UploadTask?> uploadFile(XFile? file) async {
  if (file == null) {
    print('No file was selected');
    return null;
  }

  try {
    String fileName = file.name;
    var uuid = Uuid();

    UploadTask uploadTask;
    Reference photoRef = FirebaseStorage.instance.ref().child(fileName);

    bool exists = false;
    try {
      await photoRef.getDownloadURL();
      exists = true;
    } catch (e) {
      exists = false;
    }

    if (exists) {
      var [name, ext] = splitFileName(fileName);
      String gen = uuid.v4().split('-').last;
      fileName = '$name-$gen.$ext';
      photoRef = FirebaseStorage.instance.ref().child(fileName);
    }

    final metadata = SettableMetadata(
      contentType: file.mimeType,
      customMetadata: {
        'originalName': file.name,
        'uploadTime': DateTime.now().toIso8601String(),
      },
    );

    if (kIsWeb) {
      uploadTask = photoRef.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = photoRef.putFile(io.File(file.path), metadata);
    }

    print('Upload task created for: $fileName');
    return uploadTask;
  } catch (e) {
    print('Error creating upload task: $e');
    return null;
  }
}

Future<Photo> _uploadedPhotoDefault(Reference photoRef, String email) async {
  try {
    final url = await photoRef.getDownloadURL();
    final metadata = await photoRef.getMetadata();
    final now = DateTime.now();
    final exif = await readExif(photoRef.name);

    Map<String, dynamic> record = {
      'filename': photoRef.name,
      'url': url,
      'size': metadata.size ?? 0,
      'headline': 'No name',
      'email': email,
      'nick': nickEmail(email),
      'tags': <String>[],
      'thumb': url,
      'model': 'UNKNOWN',
      'date': DateFormat(formatDate).format(now),
      'year': now.year,
      'month': now.month,
      'day': now.day,
    };
    record = {...record, ...exif};

    return Photo.fromMap(record);
  } catch (e) {
    print('Error creating photo record: $e');
    rethrow;
  }
}

class UploadTaskListTile extends StatefulWidget {
  // ignore: public_member_api_docs
  const UploadTaskListTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onUploadComplete,
  });

  final UploadTask task;
  final VoidCallback onDelete;
  final Future<void> Function(UploadTask task, String email) onUploadComplete;

  @override
  State<UploadTaskListTile> createState() => _UploadTaskListTileState();
}

class _UploadTaskListTileState extends State<UploadTaskListTile>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool _hasProcessedSuccess = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, value: 0.0)..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: widget.task.snapshotEvents,
      builder: (
        BuildContext context,
        AsyncSnapshot<TaskSnapshot> asyncSnapshot,
      ) {
        var info = '';
        TaskSnapshot? snapshot = asyncSnapshot.data;
        TaskState? state = snapshot?.state;

        if (asyncSnapshot.hasError) {
          if (asyncSnapshot.error is FirebaseException &&
              (asyncSnapshot.error as FirebaseException).code == 'canceled') {
            info = 'Upload canceled.';
          } else {
            info = 'Something went wrong.';
          }
        } else if (snapshot != null) {
          if (state == TaskState.success && !_hasProcessedSuccess) {
            _hasProcessedSuccess = true;
            print(
              'Upload task completed successfully for: ${snapshot.ref.name}',
            );
            final auth = context.read<UserBloc>().state;
            if (auth is! UserAuthenticated) {
              print('User not authenticated, skipping photo processing');
              return const SizedBox();
            }
            final email = auth.user.email;

            // Use the centralized upload completion handler
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                widget.onUploadComplete(widget.task, email);
              }
            });
          }
        }
        return ListTile(
          title: Text('${widget.task.snapshot.ref.name} $info'),
          subtitle: LinearProgressIndicator(
            value:
                widget.task.snapshot.bytesTransferred /
                widget.task.snapshot.totalBytes,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({
    super.key,
    required this.uploadedRecord,
    required this.onDelete,
    this.onEdit,
  });

  final Map<String, dynamic> uploadedRecord;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Image.network(
              uploadedRecord['url'] as String,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black87),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
