import 'package:reelriot/main.dart';
import 'package:reelriot/utils/flavor_config.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.dev,
    appName: "Reelriot (dev)",
    baseUrl: 'http://144.62.246.54:4242', // Same as prod for now
  );
  runAppWithFlavor();
}
