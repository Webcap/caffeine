import 'package:caffiene/main.dart';
import 'package:caffiene/utils/flavor_config.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.prod,
    appName: "caffeine",
    baseUrl: 'http://144.62.246.54:4242',
  );
  runAppWithFlavor();
}
