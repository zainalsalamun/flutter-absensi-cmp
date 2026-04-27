part of 'checkout_attendance_bloc.dart';

@freezed
class CheckoutAttendanceEvent with _$CheckoutAttendanceEvent {
  const factory CheckoutAttendanceEvent.started() = _Started;
  const factory CheckoutAttendanceEvent.checkout(
      String latitude, String longitude) = _Checkout;
  const factory CheckoutAttendanceEvent.checkoutWithPhoto(
      CheckInOutRequestModel request) = _CheckoutWithPhoto;
}
