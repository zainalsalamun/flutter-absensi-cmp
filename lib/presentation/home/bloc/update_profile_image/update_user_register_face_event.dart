part of 'update_user_register_face_bloc.dart';

@freezed
class UpdateUserRegisterFaceEvent with _$UpdateUserRegisterFaceEvent {
  const factory UpdateUserRegisterFaceEvent.started() = _Started;
  const factory UpdateUserRegisterFaceEvent.updateProfileImage({
    required XFile? image,
  }) = _UpdateProfileImage;
}
