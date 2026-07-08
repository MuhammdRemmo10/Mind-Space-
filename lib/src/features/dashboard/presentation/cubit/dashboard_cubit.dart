import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_dashboard_summary.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getDashboardSummary) : super(const DashboardInitial());

  final GetDashboardSummary _getDashboardSummary;

  Future<void> load() async {
    emit(const DashboardLoading());

    try {
      final summary = await _getDashboardSummary(const NoParams());
      emit(DashboardLoaded(summary));
    } catch (_) {
      emit(const DashboardFailure('Pano verileri yüklenemedi.'));
    }
  }
}
