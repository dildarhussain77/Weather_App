import 'package:weather_app1/domain/repositories/weather_repository.dart';

class GetWeatherByCoordinatesUseCase {
  GetWeatherByCoordinatesUseCase(this._repository);

  final IWeatherRepository _repository;

  Future<WeatherForecast> call(double lat, double lon) =>
      _repository.getWeatherByCoordinates(lat, lon);
}
