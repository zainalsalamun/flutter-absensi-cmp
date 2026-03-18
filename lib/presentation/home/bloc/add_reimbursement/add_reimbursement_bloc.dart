import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../data/datasources/reimbursement_remote_datasource.dart';
import '../../../../../data/models/request/checkinout_request_model.dart';

part 'add_reimbursement_bloc.freezed.dart';
part 'add_reimbursement_event.dart';
part 'add_reimbursement_state.dart';

class AddReimbursementBloc
    extends Bloc<AddReimbursementEvent, AddReimbursementState> {
  final ReimbursementRemoteDatasource datasource;
  AddReimbursementBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_AddReimbursement>(
      (event, emit) async {
        emit(const _Loading());

        final request = CheckInOutRequestModel(
          latitude: event.date,
          longitude: event.amount,
          photo: event.image?.path ?? '',
        );
        final result = await datasource.addReimbursement(request);
        result.fold(
          (l) => emit(_Error(l)),
          (r) => emit(const _Success()),
        );
      },
    );
  }
}
