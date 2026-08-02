import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // APP ICON
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Icon(
                Icons.cloud,
                size: 65,
              ),
            ),

            const SizedBox(height: 20),

            // APP NAME
            const Text(
              'Weather App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Your simple weather companion',
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            // ABOUT CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About this app',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Weather App provides current weather '
                      'information for cities around the world. '
                      'Search for a city and view temperature, '
                      'humidity, wind speed and weather conditions.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // FEATURES
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _feature(
                      context,
                      Icons.search,
                      'Search cities',
                    ),
                    _feature(
                      context,
                      Icons.thermostat,
                      'Temperature information',
                    ),
                    _feature(
                      context,
                      Icons.water_drop,
                      'Humidity information',
                    ),
                    _feature(
                      context,
                      Icons.air,
                      'Wind speed',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // DATA SOURCE
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.cloud_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Weather Data',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Powered by Artstudio',
                ),
              ),
            ),

            const SizedBox(height: 15),

            // VERSION
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                ),
                title: Text(
                  'Version',
                ),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Made with Love',
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _feature(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
