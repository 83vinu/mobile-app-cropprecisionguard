import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  String city = "Nazareth, Tuticorin";
  String temperature = '';
  String condition = '';
  String humidity = '';
  String wind = '';
  String pressure = '';
  bool isLoading = true;
  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cityController.text = city;
    fetchData(city);
  }

  Future<void> fetchData(String cityName) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=344a9b7756b844abb4d134340250904&q=$cityName&aqi=no');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = "${data['current']['temp_c']}°C";
          condition = data['current']['condition']['text'];
          humidity = "${data['current']['humidity']}%";
          wind = "${data['current']['wind_kph']} km/h";
          pressure = "${data['current']['pressure_mb']} hPa";
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Exception: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.weather_tile, style: TextStyle(color: Colors.white, fontSize: 13),),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/page_bk.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: cityController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.weather_tile,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          final enteredCity = cityController.text.trim();
                          if (enteredCity.isNotEmpty) {
                            fetchData(enteredCity);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wb_sunny, size: 80, color: Colors.orangeAccent),
                        const SizedBox(height: 10),
                        Text(
                          temperature,
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          condition,
                          style: const TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            WeatherDetail(
                              icon: Icons.water_drop,
                              label: AppLocalizations.of(context)!.weather_humidity,
                              value: humidity,
                            ),
                            WeatherDetail(
                              icon: Icons.air,
                              label: AppLocalizations.of(context)!.weather_wind,
                              value: wind,
                            ),
                            WeatherDetail(
                              icon: Icons.speed,
                              label: AppLocalizations.of(context)!.weather_pressure,
                              value: pressure,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetail({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.green[700]),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

