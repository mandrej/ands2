import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/photo.dart';

part 'uploadphoto_event.dart';
part 'uploadphoto_state.dart';

class UploadphotoBloc extends Bloc<UploadphotoEvent, UploadphotoState> {
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
