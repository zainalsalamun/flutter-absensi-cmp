import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';

import '../../../../data/models/response/user_response_model.dart';

part 'update_user_register_face_bloc.freezed.dart';
part 'update_user_register_face_event.dart';
part 'update_user_register_face_state.dart';

class UpdateUserRegisterFaceBloc
    extends Bloc<UpdateUserRegisterFaceEvent, UpdateUserRegisterFaceState> {
  final AuthRemoteDatasource authRemoteDatasource;
  UpdateUserRegisterFaceBloc(this.authRemoteDatasource)
      : super(const UpdateUserRegisterFaceState.initial()) {
    on<_UpdateProfileImage>((event, emit) async {
      emit(const UpdateUserRegisterFaceState.loading());
      try {
        if (event.image != null) {
          final user = await authRemoteDatasource.updateProfileImage(
            event.image!.path,
          );
          user.fold((l) => emit(UpdateUserRegisterFaceState.error(l)),
              (r) => emit(UpdateUserRegisterFaceState.success(r)));
        } else {
          emit(const UpdateUserRegisterFaceState.error('No image selected'));
        }
      } catch (e) {
        emit(UpdateUserRegisterFaceState.error(e.toString()));
      }
    });
  }
}
