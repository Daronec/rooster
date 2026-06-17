import 'package:rooster/config/environment/build_type.dart';
import 'package:rooster/config/environment/environment.dart';
import 'package:rooster/runner.dart';

void main() {
  run(const Environment(buildType: BuildType.dev)).ignore();
}
