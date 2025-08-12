import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';
import '../helpers/common.dart';

class UploadGridPage extends StatefulWidget {
  const UploadGridPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UploadGridPageState createState() => _UploadGridPageState();
}

class _UploadGridPageState extends State<UploadGridPage> {
  DropzoneViewController? _dropZoneController;
  final ImagePicker _picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser!;
  bool _isUploading = false;

  Future<void> _handleDroppedFiles(List<DropzoneFileInterface>? files) async {
    if (files == null || files.isEmpty) return;
    setState(() => _isUploading = true);

    List<Future> uploadTasks =
        files.map((file) async {
          final String fileName = file.name;
          Reference ref = FirebaseStorage.instance.ref().child(fileName);

          // Get file bytes directly from DropzoneFileInterface
          final bytes = await _dropZoneController!.getFileData(file);
          String? mime = await _dropZoneController!.getFileMIME(file);
          if (mime.isEmpty) {
            mime = lookupMimeType(file.name) ?? 'application/octet-stream';
          }

          if (kIsWeb) {
            // Web: upload from memory
            await ref.putData(bytes, SettableMetadata(contentType: mime));
            // await ref.putData(bytes);
          } else {
            // Desktop: write temp file and upload
            final tempFile = File('${Directory.systemTemp.path}/$fileName');
            await tempFile.writeAsBytes(bytes);
            await ref.putFile(tempFile, SettableMetadata(contentType: mime));
          }

          String downloadUrl = await ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('Photo')
              .doc(fileName)
              .set({
                'url': downloadUrl,
                'email': user.email,
                'nick': nickEmail(user.email!),
                'filename': fileName,
                'createdAt': FieldValue.serverTimestamp(),
              });
        }).toList();

    await Future.wait(uploadTasks);
    setState(() => _isUploading = false);
  }

  Future<void> _pickAndUploadImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    setState(() => _isUploading = true);

    List<Future> uploadTasks =
        images.map((img) async {
          String fileName = img.name;
          Reference ref = FirebaseStorage.instance.ref().child(fileName);
          String? mime = img.mimeType;
          if (mime == null || mime.isEmpty) {
            mime = lookupMimeType(img.path) ?? 'application/octet-stream';
          }

          try {
            if (kIsWeb) {
              // Web: use putData with bytes
              final bytes = await img.readAsBytes();
              await ref.putData(bytes, SettableMetadata(contentType: mime));
            } else {
              // Mobile/desktop: use putFile
              await ref.putFile(
                File(img.path),
                SettableMetadata(contentType: mime),
              );
            }

            String downloadUrl = await ref.getDownloadURL();

            await FirebaseFirestore.instance
                .collection('Photo')
                .doc(fileName)
                .set({
                  'url': downloadUrl,
                  'email': user.email,
                  'nick': nickEmail(user.email!),
                  'filename': fileName,
                  'createdAt': FieldValue.serverTimestamp(),
                });
          } catch (e) {
            print(e);
          }
        }).toList();

    await Future.wait(uploadTasks);
    setState(() => _isUploading = false);
  }

  Future<void> _deleteImage(String filename) async {
    print('Deleting image: $filename');
    final DocumentReference docRef = FirebaseFirestore.instance
        .collection('Photo')
        .doc(filename);
    final Reference imgRef = FirebaseStorage.instance.ref().child(filename);
    final Reference thumbRef = FirebaseStorage.instance.ref().child(
      thumbFileName(filename),
    );
    try {
      await docRef.delete();
      await imgRef.delete();
      await thumbRef.delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _editImage(String docId) async {
    final XFile? newImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (newImage == null) return;

    String fileName = newImage.name;
    //DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    if (kIsWeb) {
      final bytes = await newImage.readAsBytes();
      await ref.putData(bytes);
    } else {
      await ref.putFile(File(newImage.path));
    }
    // await ref.putFile(File(newImage.path));
    String newUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('Photo').doc(docId).update({
      'url': newUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Images"),
        actions: [
          FilledButton(
            onPressed: _isUploading ? null : _pickAndUploadImages,
            child: Text('Upload'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isUploading) LinearProgressIndicator(),
          Container(
            height: 150,
            color: Colors.grey[200],
            child: Stack(
              children: [
                DropzoneView(
                  onCreated: (controller) => _dropZoneController = controller,
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
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Photo')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(child: Text("No images uploaded."));
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data()! as Map<String, dynamic>;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(data['url'], fit: BoxFit.cover),
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
                                onPressed: () => _editImage(docs[index].id),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => _deleteImage(data['filename']),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
