/// Базовый байтовый адрес IN.Switch (состояние выключателей), см. %MB1700.
const int kEasyHomeInSwitchBaseMb = 1700;

/// База PIR в «малом» блоке (номера 1…64), схема EasyHome.
const int kEasyHomePirSmallBaseMb = 1840;

/// База PIR в расширенном блоке (номера 65…), схема EasyHome.
const int kEasyHomePirExtendedBaseMb = 10840;

/// Максимальный номер датчика в малом блоке (включительно).
const int kEasyHomePirSmallBlockLastOrdinal = 64;

/// Верхняя граница номера выключателя в UI (255).
const int _kEasyHomeLightSwitchMaxOrdinal = 255;

/// Верхняя граница номера датчика в UI (255).
const int _kEasyHomeMotionSensorMaxOrdinal = 255;

/// Верхняя граница номера группы света (лампы) в UI (255).
const int kEasyHomeLightLampOrdinalMax = 255;

/// Граница блока OldLights 1…80 / расширенный 81… ([LightDevice.extended]).
const int kEasyHomeOldLightsBlockBoundary = 80;

/// Байтовый адрес первого байта состояния лампы (%MB620/%MB8620 + 8·(N−1)), или null.
int? easyHomeLightLampStateFirstByteAddressFromOrdinal(int? ordinal) {
  if (ordinal == null) return null;
  if (ordinal < 1 || ordinal > kEasyHomeLightLampOrdinalMax) return null;
  final extended = ordinal > kEasyHomeOldLightsBlockBoundary;
  final base = extended ? 8620 : 620;
  return base + 8 * (ordinal - 1);
}

/// Байтовый адрес %MB для выключателя с порядковым номером [ordinal] (1…255).
int? easyHomeLightSwitchByteAddressFromOrdinal(int? ordinal) {
  if (ordinal == null) return null;
  if (ordinal < 1 || ordinal > _kEasyHomeLightSwitchMaxOrdinal) return null;
  return kEasyHomeInSwitchBaseMb + ordinal - 1;
}

/// Порядковый номер выключателя (1…255) из байтового адреса IN.Switch или null.
int? easyHomeLightSwitchOrdinalFromByteAddress(int? addressBytes) {
  if (addressBytes == null) return null;
  const last = kEasyHomeInSwitchBaseMb + _kEasyHomeLightSwitchMaxOrdinal - 1;
  if (addressBytes < kEasyHomeInSwitchBaseMb || addressBytes > last) {
    return null;
  }
  return addressBytes - kEasyHomeInSwitchBaseMb + 1;
}

/// Порядковый номер датчика (1…255) из строки вида `ms_N` (как в UI).
int? easyHomeMotionSensorOrdinalFromLinkId(String? id) {
  if (id == null || id.isEmpty) return null;
  if (!id.startsWith('ms_')) return null;
  final n = int.tryParse(id.substring(3));
  if (n == null || n < 1 || n > _kEasyHomeMotionSensorMaxOrdinal) return null;
  return n;
}

/// Байтовый адрес %MB для PIR по номеру [ordinal] (1…255): малый блок 1…64, далее расширенный.
int? easyHomeMotionSensorByteAddressFromOrdinal(int? ordinal) {
  if (ordinal == null) return null;
  if (ordinal < 1 || ordinal > _kEasyHomeMotionSensorMaxOrdinal) return null;
  if (ordinal <= kEasyHomePirSmallBlockLastOrdinal) {
    return kEasyHomePirSmallBaseMb + 2 * (ordinal - 1);
  }
  return kEasyHomePirExtendedBaseMb + 2 * (ordinal - 1);
}

/// Порядковый номер PIR (1…255) из байтового адреса %MB или null.
int? easyHomeMotionSensorOrdinalFromByteAddress(int? addressBytes) {
  if (addressBytes == null) return null;
  const smallLo = kEasyHomePirSmallBaseMb;
  const smallHi =
      kEasyHomePirSmallBaseMb + 2 * (kEasyHomePirSmallBlockLastOrdinal - 1);
  if (addressBytes >= smallLo && addressBytes <= smallHi) {
    if ((addressBytes - smallLo) % 2 != 0) return null;
    final n = (addressBytes - smallLo) ~/ 2 + 1;
    if (n >= 1 && n <= kEasyHomePirSmallBlockLastOrdinal) return n;
    return null;
  }
  const extLo = kEasyHomePirExtendedBaseMb;
  const extHi =
      kEasyHomePirExtendedBaseMb + 2 * (_kEasyHomeMotionSensorMaxOrdinal - 1);
  if (addressBytes >= extLo && addressBytes <= extHi) {
    if ((addressBytes - extLo) % 2 != 0) return null;
    final n = (addressBytes - extLo) ~/ 2 + 1;
    if (n > kEasyHomePirSmallBlockLastOrdinal &&
        n <= _kEasyHomeMotionSensorMaxOrdinal) {
      return n;
    }
    return null;
  }
  return null;
}
