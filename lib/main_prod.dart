import 'package:reelriot/main.dart';
import 'package:reelriot/utils/flavor_config.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.prod,
    appName: "Reelriot",
    baseUrl: 'https://caffeine.synqholdings.com/',
  );
  runAppWithFlavor();
}
