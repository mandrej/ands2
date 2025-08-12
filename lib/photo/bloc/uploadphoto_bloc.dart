import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/photo.dart';

part 'uploadphoto_event.dart';
part 'uploadphoto_state.dart';

class UploadphotoBloc extends HydratedBloc<UploadphotoEvent, UploadphotoState> {
  @override
  UploadphotoState? fromJson(Map<String, dynamic> json) {
    final photosJson = json['photos'] as List;
    final photos =
        photosJson.map<Photo>((json) => Photo.fromJson(json)).toList();
    return UploadphotoLoaded(photos);
  }

  @override
  Map<String, dynamic> toJson(UploadphotoState state) {
    final photos = state is UploadphotoLoaded ? state.photos : [];
    return {'photos': photos.map((photo) => photo.toJson()).toList()};
  }

  final List<Photo> _photos = [];

  UploadphotoBloc() : super(UploadphotoInitial()) {
    on<AddUploaded>((event, emit) {
      _photos.add(event.photo);
      emit(UploadphotoLoaded(_photos));
    });

    on<RemoveUploaded>((event, emit) {
      _photos.remove(event.photo);
      emit(UploadphotoLoaded(_photos));
    });
  }
}
