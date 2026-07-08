import '../../../../core/usecase/usecase.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummary implements UseCase<DashboardSummary, NoParams> {
  const GetDashboardSummary(this._repository);

  final DashboardRepository _repository;

  @override
  Future<DashboardSummary> call(NoParams params) {
    return _repository.getSummary();
  }
}
