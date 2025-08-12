import 'dart:async';
import 'dart:io' as io;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../task/cubit/upload_task_cubit.dart';
import '../photo/bloc/uploadphoto_bloc.dart';
import '../auth/bloc/user_bloc.dart';
import '../photo/models/photo.dart';
import '../helpers/read_exif.dart';
import '../helpers/common.dart';
import '../widgets/edit_dialog.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key, required this.title});
  final String title;

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
    // include fullPath so tasks with the same name won't collide
    final path = task.snapshot.ref.fullPath;
    final taskKey = '${task.hashCode}::$path';

    if (_processingTasks.contains(taskKey)) {
      print('Task $taskKey already processed, skipping');
      return;
    }
    _processingTasks.add(taskKey);

    try {
      // Ensure the upload is fully finished. Awaiting the task returns a TaskSnapshot.
      firebase_storage.TaskSnapshot snapshot;
      try {
        snapshot = await task;
      } catch (e) {
        // Fallback to whenComplete if awaiting the task throws for some reason
        print('Awaiting upload task failed, falling back to whenComplete: $e');
        await task.whenComplete(() {});
        snapshot = task.snapshot;
      }

      // Defensive: check snapshot state if available
      if (snapshot.state != firebase_storage.TaskState.success) {
        print(
          'Upload task completed but state is not success: ${snapshot.state}',
        );
        // still attempt to read the file below; it may become available shortly
      }

      final photo = await _uploadedPhotoDefault(snapshot.ref, email);

      if (!mounted) return;
      // tiny delay so UI can settle (keeps old behavior)
      await Future.delayed(const Duration(milliseconds: 50));

      if (mounted) {
        context.read<UploadTaskCubit>().remove(task);
        context.read<UploadphotoBloc>().add(AddUploaded(photo));
        print('Task removed and added to UploadphotoBloc: $taskKey');
      }
    } catch (error, st) {
      print('Error in _handleUploadCompletion for $taskKey: $error\n$st');
      if (mounted) {
        // remove the task so the user can retry or it won't hang in UI
        context.read<UploadTaskCubit>().remove(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing photo: $error')),
        );
      }
    } finally {
      _processingTasks.remove(taskKey);
    }
  }

  void _deleteUploadedPhoto(Photo photo) {
    context.read<UploadphotoBloc>().add(RemoveUploaded(photo));
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
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // Upload buttons section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
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
                  child: FilledButton.icon(
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
                          // onDelete: () {
                          //   task.cancel();
                          //   context.read<UploadTaskCubit>().remove(task);
                          // },
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
            child: BlocBuilder<UploadphotoBloc, UploadphotoState>(
              builder: (context, uploadedState) {
                if (uploadedState is UploadphotoLoaded &&
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
  const int maxRetries = 6;
  int attempt = 0;

  while (true) {
    try {
      // Try to read URL + metadata
      final url = await photoRef.getDownloadURL();
      final metadata = await photoRef.getMetadata();
      final now = DateTime.now();

      // readExif might rely on the filename or other helpers you have
      final exif = await readExif(photoRef.name);

      final Map<String, dynamic> record = {
        'filename': photoRef.name,
        'url': url,
        'size': metadata.size ?? 0,
        'headline': 'No name',
        'email': email,
        'nick': nickEmail(email),
        'tags': <String>[],
        'model': 'UNKNOWN',
        'date': DateFormat(formatDate).format(now),
        'year': now.year,
        'month': now.month,
        'day': now.day,
        ...exif,
      };

      return Photo.fromMap(record);
    } on firebase_storage.FirebaseException catch (e) {
      // Storage errors can return different codes depending on plugin/version.
      final code = e.code;
      final isNotFound =
          code.contains('object-not-found') || code.contains('not-found');

      if (isNotFound && attempt < maxRetries) {
        attempt++;
        final delay = Duration(milliseconds: 300 * attempt);
        print(
          'Storage object not found for ${photoRef.fullPath} (attempt $attempt/$maxRetries). Retrying in ${delay.inMilliseconds}ms...',
        );
        await Future.delayed(delay);
        continue; // try again
      }

      // Non-retryable or max attempts reached -> rethrow for upper handler
      print('Error creating photo record (storage): $e');
      rethrow;
    } catch (e) {
      // Other errors (e.g. readExif failures), rethrow so caller can handle
      print('Error creating photo record: $e');
      rethrow;
    }
  }
}

class UploadTaskListTile extends StatefulWidget {
  final firebase_storage.UploadTask task;
  final void Function(firebase_storage.UploadTask task, String email)
  onUploadComplete;

  const UploadTaskListTile({
    super.key,
    required this.task,
    required this.onUploadComplete,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UploadTaskListTileState createState() => _UploadTaskListTileState();
}

class _UploadTaskListTileState extends State<UploadTaskListTile> {
  @override
  void initState() {
    super.initState();

    final task = widget.task;
    final auth = context.read<UserBloc>().state;

    void triggerCompletion() {
      if (auth is UserAuthenticated) {
        final email = auth.user.email;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onUploadComplete(task, email);
          }
        });
      }
    }

    // ✅ Case 1: Task already finished before widget is built
    if (task.snapshot.state == firebase_storage.TaskState.success) {
      triggerCompletion();
    } else {
      // ✅ Case 2: Still uploading — attach completion listener
      task.whenComplete(triggerCompletion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_storage.TaskSnapshot>(
      stream: widget.task.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final snap = snapshot.data!;
          final progress = snap.bytesTransferred / snap.totalBytes;
          final percentage = (progress * 100).toStringAsFixed(2);

          return ListTile(
            title: Text(snap.ref.name),
            subtitle: Text('$percentage %'),
          );
        } else {
          return const ListTile(title: Text('Uploading...'));
        }
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
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
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
