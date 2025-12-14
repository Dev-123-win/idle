import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Service to handle unique device identification for strict 1-account-per-device policy
class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();

  String? _cachedDeviceId;

  /// Get the unique Device ID
  /// 1. Tries to read from Secure Storage (Persistence is key)
  /// 2. If missing, gets hardware ID or generates a UUID
  /// 3. Saves it to Secure Storage
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    // 1. Check Storage
    String? storedId = await _storage.read(key: 'device_unique_id');
    if (storedId != null) {
      _cachedDeviceId = storedId;
      return storedId;
    }

    // 2. Generate New ID (Hardware + Random Fallback)
    String newId;
    try {
      if (Platform.isAndroid) {
        await _deviceInfo.androidInfo;
        // Use a combination of hardware IDs to be robust but respectful of privacy constraints
        // We use the 'id' (build ID) as a seed but rely on our own UUID for strict uniqueness if needed.
        // Actually, for strict device locking, we want persistence.
        // Using a UUID stored in SecureStorage is the standard "Instance ID" pattern
        // which survives app updates but not uninstalls (usually).
        // To be stricter, we could use AndroidId if available, but SecureStorage UUID is safer for Play Store policies.
        newId = _uuid.v4();
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        newId = iosInfo.identifierForVendor ?? _uuid.v4();
      } else {
        newId = _uuid.v4();
      }
    } catch (e) {
      newId = _uuid.v4();
    }

    // 3. Save
    await _storage.write(key: 'device_unique_id', value: newId);
    _cachedDeviceId = newId;
    return newId;
  }
}
