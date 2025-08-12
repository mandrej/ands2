// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

final class Photo extends Equatable {
  const Photo({
    required this.filename,
    required this.headline,
    this.tags = const [],
    required this.email,
    required this.nick,
    required this.url,
    this.thumb,
    required this.date,
    required this.year,
    required this.month,
    required this.day,
    required this.size,
    this.model = '',
    this.lens = '',
    this.focal_length = 0,
    this.aperture = 0,
    this.shutter = '',
    this.iso = 0,
    this.flash = false,
    this.loc = '',
    this.text = const [],
  });

  final String filename;
  final String headline;
  final List<String>? tags;
  final String email;
  final String nick;
  final String url;
  final String? thumb;
  final String date;
  final int year;
  final int month;
  final int day;
  final int size;
  final String? model;
  final String? lens;
  final int? focal_length;
  final double? aperture;
  final String? shutter;
  final int? iso;
  final bool? flash;
  final String? loc;
  final List<String>? text;

  @override
  List<Object?> get props => [
    filename,
    headline,
    tags,
    email,
    nick,
    url,
    thumb,
    date,
    year,
    month,
    day,
    size,
    model,
    lens,
    focal_length,
    aperture,
    shutter,
    iso,
    flash,
    loc,
    text,
  ];

  Photo copyWith({
    String? filename,
    String? headline,
    List<String>? tags,
    String? email,
    String? nick,
    String? url,
    String? thumb,
    String? date,
    int? year,
    int? month,
    int? day,
    int? size,
    String? model,
    String? lens,
    int? focal_length,
    double? aperture,
    String? shutter,
    int? iso,
    bool? flash,
    String? loc,
    List<String>? text,
  }) {
    return Photo(
      filename: filename ?? this.filename,
      headline: headline ?? this.headline,
      tags: tags ?? this.tags,
      email: email ?? this.email,
      nick: nick ?? this.nick,
      url: url ?? this.url,
      thumb: thumb ?? this.thumb,
      date: date ?? this.date,
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      size: size ?? this.size,
      model: model ?? this.model,
      lens: lens ?? this.lens,
      focal_length: focal_length ?? this.focal_length,
      aperture: aperture ?? this.aperture,
      shutter: shutter ?? this.shutter,
      iso: iso ?? this.iso,
      flash: flash ?? this.flash,
      loc: loc ?? this.loc,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'filename': filename,
      'headline': headline,
      'tags': tags,
      'email': email,
      'nick': nick,
      'url': url,
      'thumb': thumb,
      'date': date,
      'year': year,
      'month': month,
      'day': day,
      'size': size,
      'model': model,
      'lens': lens,
      'focal_length': focal_length,
      'aperture': aperture,
      'shutter': shutter,
      'iso': iso,
      'flash': flash,
      'loc': loc,
      'text': text,
    };
  }

  static Photo fromMap(Map<String, dynamic> map) {
    return Photo(
      filename: map['filename'] as String,
      headline: map['headline'] as String,
      tags: map['tags']?.cast<String>(),
      email: map['email'] as String,
      nick: map['nick'] as String,
      url: map['url'] as String,
      thumb: map['thumb'] as String?,
      date: map['date'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      day: map['day'] as int,
      size: map['size'] as int,
      model: map['model'] as String?,
      lens: map['lens'] as String?,
      focal_length: map['focal_length'] as int?,
      aperture: map['aperture'] as double?,
      shutter: map['shutter'] as String?,
      iso: map['iso'] as int?,
      flash: map['flash'] as bool?,
      loc: map['loc'] as String?,
      text: map['text']?.cast<String>(),
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json) => Photo.fromMap(json);

  Map<String, dynamic> toJson() => toMap();
}
