import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_absensi_app/data/models/response/reimbursement_response_model.dart';

import '../../../../../data/datasources/reimbursement_remote_datasource.dart';

part 'get_reimbursements_bloc.freezed.dart';
part 'get_reimbursements_event.dart';
part 'get_reimbursements_state.dart';

class GetReimbursementsBloc
    extends Bloc<GetReimbursementsEvent, GetReimbursementsState> {
  final ReimbursementRemoteDatasource datasource;
  GetReimbursementsBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_GetReimbursements>(
      (event, emit) async {
        emit(const _Loading());

        final result = await datasource.getReimbursements();
        result.fold(
          (l) => emit(_Error(l)),
          (r) => emit(_Success(r)),
        );
      },
    );
  }
}
