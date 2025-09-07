import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import '../auth/bloc/user_bloc.dart';
import '../helpers/common.dart';
import '../photo/models/photo.dart';
import '../photo/bloc/uploadphoto_bloc.dart';
import '../widgets/edit_dialog.dart';

class UploadGridPage extends StatefulWidget {
  const UploadGridPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UploadGridPageState createState() => _UploadGridPageState();
}

class _UploadGridPageState extends State<UploadGridPage> {
  DropzoneViewController? _dropZoneController;
  final ImagePicker _picker = ImagePicker();
  final user = UserBloc().state.user!;
  final storage = FirebaseStorage.instance;
  bool _isUploading = false;

  Photo _photoDefault(String fileName, String downloadUrl, int? size) {
    final now = DateTime.now();
    return Photo(
      filename: fileName,
      url: downloadUrl,
      size: size ?? 0,
      headline: 'No name',
      email: user.email,
      nick: nickEmail(user.email!),
      tags: <String>[],
      model: 'UNKNOWN',
      date: DateFormat(formatDate).format(now),
      year: now.year,
      month: now.month,
      day: now.day,
    );
  }

  Future<void> _handleDroppedFiles(List<DropzoneFileInterface>? files) async {
    if (files == null || files.isEmpty) return;
    setState(() => _isUploading = true);

    List<Future> uploadTasks =
        files.map((file) async {
          final String fileName = '${const Uuid().v4()}___${file.name}';
          Reference ref = storage.ref().child(fileName);

          final bytes = await _dropZoneController!.getFileData(file);
          String? mime = await _dropZoneController!.getFileMIME(file);
          if (mime.isEmpty) {
            mime = lookupMimeType(file.name) ?? 'application/octet-stream';
          }
          final size = await _dropZoneController!.getFileSize(file);

          if (kIsWeb) {
            await ref.putData(bytes, SettableMetadata(contentType: mime));
          } else {
            final tempFile = File('${Directory.systemTemp.path}/$fileName');
            await tempFile.writeAsBytes(bytes);
            await ref.putFile(tempFile, SettableMetadata(contentType: mime));
          }

          String downloadUrl = await ref.getDownloadURL();
          final photo = _photoDefault(fileName, downloadUrl, size);
          context.read<UploadphotoBloc>().add(AddUploaded(photo));
        }).toList();
    _errorHandling(uploadTasks);
  }

  Future<void> _pickAndUploadImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    setState(() => _isUploading = true);

    List<Future> uploadTasks =
        images.map((img) async {
          String fileName = '${const Uuid().v4()}___${img.name}';
          Reference ref = storage.ref().child(fileName);

          final bytes = await img.readAsBytes();
          String? mime = img.mimeType;
          if (mime == null || mime.isEmpty) {
            mime = lookupMimeType(img.path) ?? 'application/octet-stream';
          }
          final size = await img.length();

          if (kIsWeb) {
            await ref.putData(bytes, SettableMetadata(contentType: mime));
          } else {
            await ref.putFile(
              File(img.path),
              SettableMetadata(contentType: mime),
            );
          }

          String downloadUrl = await ref.getDownloadURL();
          final photo = _photoDefault(fileName, downloadUrl, size);
          context.read<UploadphotoBloc>().add(AddUploaded(photo));
        }).toList();

    _errorHandling(uploadTasks);
  }

  Future<void> _errorHandling(uploadTasks) async {
    try {
      await Future.wait(
        uploadTasks,
        eagerError: true, // stop at first error
      );
    } catch (e, stack) {
      debugPrint('Error while uploading files: $e');
      debugPrintStack(stackTrace: stack);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow; // optional if you want the error to propagate
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteImage(Photo photo) async {
    context.read<UploadphotoBloc>().add(RemoveUploaded(photo));
    // setState(() {});

    final Reference imgRef = storage.ref().child(photo.filename);
    final Reference thumbRef = storage.ref().child(
      thumbFileName(photo.filename),
    );
    try {
      await imgRef.delete();
      await thumbRef.delete();
    } catch (e) {
      print(e);
    }
  }

  void _editImage(Map<String, dynamic> record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditDialog(editRecord: Photo.fromMap(record)),
      ),
    );
  }

  @override
  /// Builds the UI for the UploadPage, which displays a form for uploading
  /// images and a grid of uploaded images.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Images"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FilledButton(
              onPressed: _isUploading ? null : _pickAndUploadImages,
              child: Text('Upload'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_isUploading) LinearProgressIndicator(),
            if (kIsWeb)
              Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                height: 150,
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    DropzoneView(
                      onCreated:
                          (controller) => _dropZoneController = controller,
                      onDropFiles: _handleDroppedFiles,
                      mime: ['image/jpeg', 'image/png', 'image/gif'],
                    ),
                    Center(
                      child: Text(
                        "Drag & Drop Images Here",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: BlocConsumer<UploadphotoBloc, UploadphotoState>(
                listener: (context, state) {
                  if (state is UploadphotoLoaded) {
                    setState(() {}); // Update the UI when the state changes
                  }
                },
                builder: (context, state) {
                  if (state is UploadphotoLoaded) {
                    final photos = state.photos;
                    if (photos.isEmpty) {
                      return Center(child: Text("No images uploaded."));
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width ~/ 200,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 1,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(photo.url, fit: BoxFit.cover),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed:
                                          () => _editImage(photo.toMap()),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _deleteImage(photo),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No images uploaded."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
