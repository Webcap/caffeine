import 'package:reelriot/main.dart';
import 'package:reelriot/utils/flavor_config.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.dev,
    appName: "Reelriot (dev)",
    baseUrl: 'https://caffeine.synqholdings.com/', // Updated from dead IP
  );
  runAppWithFlavor();
}
