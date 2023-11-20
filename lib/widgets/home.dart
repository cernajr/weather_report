import 'package:weather_report/class/weather.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Weather> futureWeather;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeather('honduras');
  }

  Future<Weather> fetchWeather(String country) async {
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=b28e4669702f432a8f3234601231911&q=$country&aqi=yes'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al carga el clima');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Report'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FutureBuilder<Weather>(
              future: futureWeather,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 100), // Espacio adicional
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centrar la fila
                        children: <Widget>[
                          const Icon(
                            Icons.location_on,
                            size: 30,
                            color: Colors.red,
                          ), // Icono más grande
                          const SizedBox(
                              width: 10), // Espacio entre el icono y el texto
                          Text(
                            'Ubicacion: ${snapshot.data!.location.name}, ${snapshot.data!.location.region}, ${snapshot.data!.location.country}',
                            style: const TextStyle(
                                fontSize: 20), // Texto más grande
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Espacio adicional
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.thermostat_outlined,
                              size: 30, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('Temperatura: ${snapshot.data!.current.tempC}°C',
                              style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 20), // Espacio adicional
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            getWeatherIcon(
                                snapshot.data!.current.condition.text),
                            size: 30,
                            color: getConditionColor(
                                snapshot.data!.current.condition.text),
                          ),
                          const SizedBox(width: 10),
                          Text(
                              'Condicion: ${snapshot.data!.current.condition.text}',
                              style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 20), // Espacio adicional
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.air, size: 30),
                          const SizedBox(width: 10),
                          Text(
                              'Velocidad del viento: ${snapshot.data!.current.windKph} kph',
                              style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 20), // Espacio adicional
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.access_time, size: 30),
                          const SizedBox(width: 10),
                          Text(
                              'Hora: ${TimeOfDay.fromDateTime(DateTime.now()).format(context)}',
                              style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 100), // Espacio adicional
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(width: 100),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Escribe una ciudad',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  futureWeather = fetchWeather(_controller.text);
                });
              },
              child: const Text('Buscar'),
            ),
          ],
        ),
      ),
    );
  }
}

IconData getWeatherIcon(String condition) {
  if (condition.toLowerCase().contains('sunny')) {
    return Icons.wb_sunny;
  } else if (condition.toLowerCase().contains('cloudy')) {
    return Icons.cloud;
  } else if (condition.toLowerCase().contains('rain')) {
    return Icons.grain;
  } else {
    return Icons.wb_cloudy;
  }
}

Color getConditionColor(String condition) {
  if (condition.toLowerCase().contains('sunny')) {
    return Colors.yellow;
  } else if (condition.toLowerCase().contains('cloudy')) {
    return Colors.grey;
  } else if (condition.toLowerCase().contains('rain')) {
    return Colors.blue;
  } else {
    return Colors.black; // Color por defecto
  }
}
