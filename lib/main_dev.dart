import 'package:caffiene/main.dart';
import 'package:caffiene/utils/flavor_config.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.dev,
    appName: "Caffeine (dev)",
    baseUrl: 'http://144.62.246.54:4242', // Same as prod for now
  );
  runAppWithFlavor();
}
