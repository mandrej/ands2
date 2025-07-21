import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:exif/exif.dart';
import 'package:intl/intl.dart';
import 'common.dart';

double handleRatio(IfdValues val) {
  final r = val.toList().first;
  return r.toDouble();
}

double decimalCoords(IfdValues val, String ref) {
  List<dynamic> coords = val.toList();
  double decimalDegrees =
      coords[0].toDouble() +
      coords[1].toDouble() / 60 +
      coords[2].toDouble() / 3600;
  if (ref == 'S' || ref == 'W') {
    decimalDegrees = -decimalDegrees;
  }
  return decimalDegrees;
}

Future readExif(filename) async {
  Map<String, dynamic>? result = {};
  Reference ref = FirebaseStorage.instance.ref().child(filename);
  try {
    const maxSize = 4 * 1024 * 1024;
    final Uint8List? data = await ref.getData(maxSize);

    if (data == null) {
      print('Failed to retrieve data from Firebase Storage');
      return result;
    }
    final exif = await readExifFromBytes(data);
    // Data for "images/island.jpg" is returned, use this as needed.
    if (exif.isEmpty) {
      print('No EXIF information found');
      return result;
    }

    // for (final entry in exif.entries) {
    //   print("${entry.key}: ${entry.value}");
    // }
    result['model'] = exif['Image Model'].toString();
    result['lens'] = exif['EXIF LensModel'].toString().replaceAll('/', '');
    // 2025:03:30 19:05:04
    var fixDate = exif['EXIF DateTimeOriginal'].toString().replaceAllMapped(
      RegExp(r'(\d{4}):(\d{2}):(\d{2})'),
      (match) => '${match[1]}-${match[2]}-${match[3]}',
    );
    var date = DateTime.parse(fixDate);
    result['date'] = DateFormat(formatDate).format(date);
    result['year'] = date.year;
    result['month'] = date.month;
    result['day'] = date.day;

    result['aperture'] = handleRatio(exif['EXIF FNumber']!.values);
    result['focal_length'] = handleRatio(exif['EXIF FocalLength']!.values);

    result['shutter'] = exif['EXIF ExposureTime'].toString();
    result['iso'] = int.tryParse(exif['EXIF ISOSpeedRatings'].toString());

    result['flash'] =
        !exif['EXIF Flash'].toString().startsWith('Flash did not');

    if (exif.containsKey('GPS GPSLatitude') &&
        exif.containsKey('GPS GPSLongitudeRef') &&
        exif.containsKey('GPS GPSLongitude') &&
        exif.containsKey('GPS GPSLongitudeRef')) {
      result['loc'] = [
        decimalCoords(
          exif['GPS GPSLatitude']!.values,
          exif['GPS GPSLatitudeRef'].toString(),
        ),
        decimalCoords(
          exif['GPS GPSLongitude']!.values,
          exif['GPS GPSLongitudeRef'].toString(),
        ),
      ].join(',');
    }

    /*
    Image Make: NIKON CORPORATION
    Image Model: NIKON Z 6_2
    Image XResolution: 240
    Image YResolution: 240
    Image ResolutionUnit: Pixels/Inch
    Image Software: Adobe Lightroom 8.2 (Macintosh)
    Image DateTime: 2025:03:31 10:55:55
    Image Artist: MILAN ANDREJEVIC
    Image Copyright: MILAN ANDREJEVIC
    Image ExifOffset: 280
    GPS GPSVersionID: [2, 3, 0, 0]
    GPS GPSLatitudeRef: N
    GPS GPSLatitude: [44, 61063/1250, 0]
    GPS GPSLongitudeRef: E
    GPS GPSLongitude: [20, 276433/10000, 0]
    GPS GPSAltitudeRef: 0
    GPS GPSAltitude: 160
    GPS GPSTimeStamp: [17, 1, 609/20]
    GPS GPSSatellites: 00
    GPS GPSMapDatum: WGS-84
    GPS GPSDate: 2025:03:30
    Image GPSInfo: 1028
    Thumbnail Compression: JPEG (old-style)
    Thumbnail XResolution: 72
    Thumbnail YResolution: 72
    Thumbnail ResolutionUnit: Pixels/Inch
    Thumbnail JPEGInterchangeFormat: 1360
    Thumbnail JPEGInterchangeFormatLength: 16168
    EXIF ExposureTime: 1/125
    EXIF FNumber: 16/5
    EXIF ExposureProgram: Shutter Priority
    EXIF ISOSpeedRatings: 100
    EXIF SensitivityType: Recommended Exposure Index
    EXIF RecommendedExposureIndex: 100
    EXIF ExifVersion: 0231
    EXIF DateTimeOriginal: 2025:03:30 19:05:04
    EXIF DateTimeDigitized: 2025:03:30 19:05:04
    EXIF OffsetTime: +02:00
    EXIF OffsetTimeOriginal: +02:00
    EXIF OffsetTimeDigitized: +02:00
    EXIF ShutterSpeedValue: 870723/125000
    EXIF ApertureValue: 209759/62500
    EXIF ExposureBiasValue: -1
    EXIF MeteringMode: Pattern
    EXIF LightSource: Unknown
    EXIF Flash: Flash did not fire
    EXIF FocalLength: 50
    EXIF SubSecTimeOriginal: 12
    EXIF SubSecTimeDigitized: 12
    EXIF ColorSpace: sRGB
    EXIF FocalPlaneXResolution: 13787681/8192
    EXIF FocalPlaneYResolution: 13787681/8192
    EXIF FocalPlaneResolutionUnit: 3
    EXIF SensingMethod: One-chip color area
    EXIF FileSource: Digital Camera
    EXIF SceneType: Directly Photographed
    EXIF CVAPattern: [2, 0, 2, 0, 0, 1, 1, 2]
    EXIF CustomRendered: Custom
    EXIF ExposureMode: Auto Exposure
    EXIF WhiteBalance: Auto
    EXIF FocalLengthIn35mmFilm: 50
    EXIF SceneCaptureType: Standard
    EXIF GainControl: None
    EXIF Contrast: Normal
    EXIF Saturation: Normal
    EXIF Sharpness: Normal
    EXIF SubjectDistanceRange: 0
    EXIF BodySerialNumber: 6102829
    EXIF LensSpecification: [50, 50, 9/5, 9/5]
    EXIF LensMake: NIKON
    EXIF LensModel: NIKKOR Z 50mm f/1.8 S
    EXIF LensSerialNumber: 20087028
    */
  } on FirebaseException catch (e) {
    print(e);
  }
  // MISSING dim: [3200, 2129]
  return result;
}
