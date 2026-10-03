import "package:battery_plus/battery_plus.dart";
import "package:connectivity_plus/connectivity_plus.dart";

abstract interface class DeviceConditions {
  Future<bool> isOnUnmeteredNetwork();

  Future<bool> isCharging();
}

class PlatformDeviceConditions implements DeviceConditions {
  PlatformDeviceConditions({Connectivity? connectivity, Battery? battery})
    : _connectivity = connectivity ?? Connectivity(),
      _battery = battery ?? Battery();

  final Connectivity _connectivity;
  final Battery _battery;

  static const _unmetered = {ConnectivityResult.wifi, ConnectivityResult.ethernet};
  static const _powered = {BatteryState.charging, BatteryState.full, BatteryState.connectedNotCharging};

  @override
  Future<bool> isOnUnmeteredNetwork() async => (await _connectivity.checkConnectivity()).any(_unmetered.contains);

  @override
  Future<bool> isCharging() async => _powered.contains(await _battery.batteryState);
}
