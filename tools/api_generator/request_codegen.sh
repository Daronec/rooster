#!/usr/bin/env bash

### Generate swagger configuration
for i in $(find ../../../ekf.sales-flutter/**/api.yaml); do
  ./apple_silicon_generator generate "$i" -c request_config.yaml -n "$(basename $(dirname "$i"))" -r
done

### Move to project folder
cd ../..

### Generate all *.g.dart files
fvm flutter clean && fvm flutter pub get && fvm flutter pub run build_runner build --delete-conflicting-outputs

### Format all generated files
sh scripts/format.sh
