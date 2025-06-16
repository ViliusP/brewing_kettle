/// This enum represents different temperature scales and provides methods
/// to convert between them. It includes Celsius, Fahrenheit, and Kelvin.
/// Each scale has a name and a symbol, and methods to convert a temperature
/// value from one scale to another.
///
/// Example usage:
/// ```dart
/// TemperatureScale celsius = TemperatureScale.celsius;
/// double tempInFahrenheit = celsius.toFahrenheit(25); // Converts 25°C to °F
/// double tempInKelvin = celsius.toKelvin(25); // Converts 25°C to K
/// ```
enum TemperatureScale {
  celsius("celsius", "°C"),
  fahrenheit("fahrenheit", "°F"),
  kelvin("kelvin", "K");

  const TemperatureScale(this.name, this.symbol);

  final String name;
  final String symbol;

  double fromCelsius(double value) {
    return switch (this) {
      TemperatureScale.celsius => value,
      TemperatureScale.fahrenheit => (value * 9 / 5) + 32,
      TemperatureScale.kelvin => value + 273.15,
    };
  }

  double toCelsius(double value) {
    return switch (this) {
      TemperatureScale.celsius => value,
      TemperatureScale.fahrenheit => (value - 32) * 5 / 9,
      TemperatureScale.kelvin => value - 273.15,
    };
  }

  double fromFahrenheit(double value) {
    return switch (this) {
      TemperatureScale.celsius => (value - 32) * 5 / 9,
      TemperatureScale.fahrenheit => value,
      TemperatureScale.kelvin => (value - 32) * 5 / 9 + 273.15,
    };
  }

  double toFahrenheit(double value) {
    return switch (this) {
      TemperatureScale.celsius => (value * 9 / 5) + 32,
      TemperatureScale.fahrenheit => value,
      TemperatureScale.kelvin => (value - 273.15) * 9 / 5 + 32,
    };
  }

  double fromKelvin(double value) {
    return switch (this) {
      TemperatureScale.celsius => value - 273.15,
      TemperatureScale.fahrenheit => (value - 273.15) * 9 / 5 + 32,
      TemperatureScale.kelvin => value,
    };
  }

  double toKelvin(double value) {
    return switch (this) {
      TemperatureScale.celsius => value + 273.15,
      TemperatureScale.fahrenheit => (value - 32) * 5 / 9 + 273.15,
      TemperatureScale.kelvin => value,
    };
  }
}
