import 'package:equatable/equatable.dart';

final class Find extends Equatable {
  const Find({
    this.year,
    this.month,
    this.tags,
    this.model,
    this.lens,
    this.nick,
  });

  final int? year;
  final int? month;
  final List<String>? tags;
  final String? model;
  final String? lens;
  final String? nick;

  static Find fromJson(Map<String, dynamic> json) {
    return Find(
      year: json['year'] as int?,
      month: json['month'] as int?,
      tags: json['tags']?.cast<String>(),
      model: json['model'] as String?,
      lens: json['lens'] as String?,
      nick: json['nick'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'tags': tags,
      'model': model,
      'lens': lens,
      'nick': nick,
    };
  }

  @override
  List<Object?> get props => [year, month, tags, model, lens, nick];

  Find copyWithField(String key, dynamic value) {
    switch (key) {
      case 'year':
        return Find(
          year: value as int?,
          month: month,
          tags: tags,
          model: model,
          lens: lens,
          nick: nick,
        );
      case 'month':
        return Find(
          year: year,
          month: value as int?,
          tags: tags,
          model: model,
          lens: lens,
          nick: nick,
        );
      case 'tags':
        return Find(
          year: year,
          month: month,
          tags: (value as List<dynamic>?)?.cast<String>(),
          model: model,
          lens: lens,
          nick: nick,
        );
      case 'model':
        return Find(
          year: year,
          month: month,
          tags: tags,
          model: value as String?,
          lens: lens,
          nick: nick,
        );
      case 'lens':
        return Find(
          year: year,
          month: month,
          tags: tags,
          model: model,
          lens: value as String?,
          nick: nick,
        );
      case 'nick':
        return Find(
          year: year,
          month: month,
          tags: tags,
          model: model,
          lens: lens,
          nick: value as String?,
        );
      default:
        return this;
    }
  }

  @override
  String toString() =>
      'Find(year: $year, month: $month, tags: $tags, model: $model, lens: $lens, nick: $nick)';
}
