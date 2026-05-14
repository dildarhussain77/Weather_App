import 'package:dio/dio.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';

class GetCitySuggestionsUseCase {
  GetCitySuggestionsUseCase(this._repository);

  final IWeatherRepository _repository;

  Future<List<CitySuggestion>> call(
    String query, {
    CancelToken? cancelToken,
  }) =>
      _repository.getCitySuggestions(query, cancelToken: cancelToken);
}
