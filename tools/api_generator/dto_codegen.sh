#!/usr/bin/env bash

data_output_path=../../lib/api/data
umbrella_file_name=umbrella.dart

### Generate swagger configuration
### TODO(init-project): Replace "flutter-template-swagger" with your Swagger repository name.
for i in $(find ../../../ekf.sales-flutter/**/api.yaml); do
  ./apple_silicon_generator generate "$i" -v -c dto_config.yaml -n "$(basename $(dirname "$i"))" -r
done

### Move to data api folder
cd ${data_output_path}

### Generate all *.g.dart files
fvm flutter clean \
  && fvm flutter pub get \
  && fvm flutter pub run build_runner build --delete-conflicting-outputs

### Remove previous generated export file
rm -f ${umbrella_file_name}

### Iterate over all files, except *.g.dart files
rm -rf build
fileNames=()
filter=".g.dart"
for file in *
do
  nameAndExt=${file##*/}
    if [[ "$nameAndExt" != *"$filter"* ]]; then
        fileNames+=("$nameAndExt")
    fi
done

### Create new umbrella file
for value in "${fileNames[@]}"
do
  name=${value%.*}
  echo "export '$name.dart';" >> "$umbrella_file_name"
done

### Format all generated files
(cd ../../.. && sh scripts/format.sh)
