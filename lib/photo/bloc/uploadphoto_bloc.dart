import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'uploadphoto_event.dart';
part 'uploadphoto_state.dart';

class UploadphotoBloc extends Bloc<UploadphotoEvent, UploadphotoState> {
  UploadphotoBloc() : super(UploadphotoInitial()) {
    on<UploadphotoEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
