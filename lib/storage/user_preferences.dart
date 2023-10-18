
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/region_config.dart';

class UserPreferences {
  const UserPreferences();
  final _storage = const FlutterSecureStorage();

  Future<List<RegionConfig>> readAll() async => await _storage.readAll(
      iOptions: getIOSOptions(),
      aOptions: getAndroidOptions(),
    ).then((value) => value.entries.map((entry) => RegionConfig.deserialize(entry.value)).toList(growable: true));

  Future<RegionConfig> readSelected() async => await readAll()
      .then((value) => value.where((element) => element.selected).firstOrNull ?? RegionConfig.defaultConfig());

  Future<void> write(final RegionConfig config) async => await _storage.write(
        key: config.name,
        value: RegionConfig.serialize(config),
        iOptions: getIOSOptions(),
        aOptions: getAndroidOptions(),
      );

  IOSOptions getIOSOptions() => const IOSOptions(accessibility: KeychainAccessibility.first_unlock);
  AndroidOptions getAndroidOptions() => const AndroidOptions(encryptedSharedPreferences: true);
}
