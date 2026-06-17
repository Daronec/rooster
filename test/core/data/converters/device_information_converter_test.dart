import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/api/data/device_information_dto.dart';
import 'package:rooster/core/data/converters/device_information_converter.dart';
import 'package:rooster/core/domain/entities/device_information/device_type.dart';

void main() {
  const dtoConverter = DeviceInformationConverter(
    deviceTypeConverter: DeviceTypeConverter(),
  );
  const typeConverter = DeviceTypeConverter();

  group('DeviceTypeConverter', () {
    test('android', () {
      expect(typeConverter.convert('android'), DeviceType.android);
    });

    test('ios', () {
      expect(typeConverter.convert('ios'), DeviceType.ios);
    });

    test('неизвестный ключ — исключение', () {
      expect(() => typeConverter.convert('unknown_os'), throwsStateError);
    });
  });

  group('DeviceInformationConverter', () {
    test('os null — entity без ОС', () {
      const dto = DeviceInformationDto(
        device: 'Pixel',
        osVersion: '14',
      );
      final entity = dtoConverter.convert(dto);
      expect(entity.os, isNull);
      expect(entity.device, 'Pixel');
      expect(entity.osVersion, '14');
    });

    test('полный DTO — маппинг полей', () {
      const dto = DeviceInformationDto(
        device: 'iPhone',
        os: 'ios',
        osVersion: '17.0',
      );
      final entity = dtoConverter.convert(dto);
      expect(entity.os, DeviceType.ios);
      expect(entity.device, 'iPhone');
      expect(entity.osVersion, '17.0');
    });
  });
}
