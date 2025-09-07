import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/photo.dart';

part 'uploadphoto_event.dart';
part 'uploadphoto_state.dart';

class UploadphotoBloc extends HydratedBloc<UploadphotoEvent, UploadphotoState> {
  final List<Photo> _photos = [];

  UploadphotoBloc() : super(UploadphotoInitial()) {
    on<AddUploaded>(_onAddUploaded);
    on<RemoveUploaded>(_onRemoveUploaded);
  }

  void _onAddUploaded(AddUploaded event, Emitter<UploadphotoState> emit) {
    _photos.add(event.photo);
    emit(UploadphotoLoaded(_photos));
  }

  void _onRemoveUploaded(RemoveUploaded event, Emitter<UploadphotoState> emit) {
    _photos.remove(event.photo);
    emit(UploadphotoLoaded(_photos));
  }

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
}
