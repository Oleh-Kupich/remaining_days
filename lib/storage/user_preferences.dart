
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:remaining_days/models/region_config.dart';

class UserPreferences {

  static const _storage = FlutterSecureStorage();

  Future<List<RegionConfig>> readAll() async => _storage.readAll(
      iOptions: getIOSOptions(),
      aOptions: getAndroidOptions(),
    ).then((value) => value.entries.map((entry) => RegionConfig.deserialize(entry.value)).toList(growable: true));

  Future<RegionConfig?> readSelected() async => readAll()
      .then((value) => value.where((element) => element.selected).firstOrNull);

  Future<void> write(RegionConfig config) async => _storage.write(
        key: config.name,
        value: RegionConfig.serialize(config),
        iOptions: getIOSOptions(),
        aOptions: getAndroidOptions(),
      );

  IOSOptions getIOSOptions() => const IOSOptions(accessibility: KeychainAccessibility.first_unlock);
  AndroidOptions getAndroidOptions() => const AndroidOptions(encryptedSharedPreferences: true);
}
