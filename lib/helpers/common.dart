import 'dart:convert';

import 'package:path/path.dart' as p;

part '../config.dart';

String formatDate = 'yyyy-MM-dd HH:mm';

String nickEmail(String email) {
  return familyMap[email] ?? email.split('@')[0];
}

List<String> splitFileName(String fileName) {
  // final regex = RegExp(r'^(.*?)(?:\.([^.]*))?$');
  // var res = <String>[];
  // var matches = regex.allMatches(fileName);
  // for (final m in matches) {
  //   res.add(m[0]!);
  // }
  // return res[2];
  final result = pathSplit(fileName);
  return [result.name, result.extension ?? ''];
}

({String name, String? extension}) pathSplit(String path) {
  final baseName = p.basename(path);
  if (baseName.isEmpty || baseName == '.' || baseName == '..') {
    return (name: baseName, extension: null);
  }
  final rawExtension = p.extension(baseName); // e.g., ".pdf", ".gz", or ""
  final nameWithoutExtension = p.basenameWithoutExtension(
    baseName,
  ); // e.g., "document", "archive.tar"
  final String? extension =
      (rawExtension.isEmpty || rawExtension == '.')
          ? null
          : rawExtension.substring(1);

  return (name: nameWithoutExtension, extension: extension);
}

String thumbFileName(String fileName) {
  var [name, ext] = splitFileName(fileName);
  return 'thumbnails/${name}_400x400.jpeg';
}

String prettyJson(Object jsonObject) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(jsonObject);
}
