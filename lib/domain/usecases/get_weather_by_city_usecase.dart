import 'package:weather_app1/domain/repositories/weather_repository.dart';

class GetWeatherByCityUseCase {
  GetWeatherByCityUseCase(this._repository);

  final IWeatherRepository _repository;

  Future<WeatherForecast> call(String city) =>
      _repository.getWeatherByCity(city);
}
