import 'dart:convert';

String formatDate = 'yyyy-MM-dd HH:mm';

String nickEmail(String email) {
  final regex = RegExp(r'[^.@]+');
  var match = regex.stringMatch(email);
  if (match != null) {
    return match;
  }
  // Return an empty string or throw an error if no match is found
  return '';
}

List<String> splitFileName(String fileName) {
  // final regex = RegExp(r'[^.]+');
  // var res = <String>[];
  // var matches = regex.allMatches(fileName);
  // for (final m in matches) {
  //   res.add(m[0]!);
  // }
  // return res;
  return fileName.split('.');
}

String thumbFileName(String fileName) {
  var [name, ext] = splitFileName(fileName);
  return '${name}_400x400.jpeg';
}

String prettyJson(Object jsonObject) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(jsonObject);
}
