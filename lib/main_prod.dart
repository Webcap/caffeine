import 'package:reelriot/main.dart';
import 'package:reelriot/utils/flavor_config.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.prod,
    appName: "Reelriot",
    baseUrl: 'http://144.62.246.54:4242',
  );
  runAppWithFlavor();
}
