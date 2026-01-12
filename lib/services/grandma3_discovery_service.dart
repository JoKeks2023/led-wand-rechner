import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/dmx_models.dart';

/// Represents a discovered GrandMA 3 console
class DiscoveredConsole {
  final String hostname;
  final String ipAddress;
  final int port;
  final String version;
  final DateTime discoveredAt;

  DiscoveredConsole({
    required this.hostname,
    required this.ipAddress,
    required this.port,
    required this.version,
    required this.discoveredAt,
  });

  GrandMA3Config toConfig() {
    return GrandMA3Config(
      hostname: hostname,
      ipAddress: ipAddress,
      oscPort: port,
      version: version,
      autoDiscoveryUsed: true,
    );
  }

  @override
  String toString() => '$hostname ($ipAddress:$port) v$version';
}

/// GrandMA 3 Auto-Discovery Service
/// Strategies:
/// 1. mDNS discovery (_grandma._tcp.local)
/// 2. UDP broadcast on local network
/// 3. IP range scanning (fallback)
class GrandMA3DiscoveryService with ChangeNotifier {
  static const int _oscPort = 7000;
  static const int _discoveryTimeoutSeconds = 5;
  static const String _mdnsServiceName = '_grandma._tcp.local';

  final NetworkInfo _networkInfo;

  List<DiscoveredConsole> _discoveredConsoles = [];
  bool _isDiscovering = false;
  String? _lastError;

  GrandMA3DiscoveryService({NetworkInfo? networkInfo})
      : _networkInfo = networkInfo ?? NetworkInfo();

  List<DiscoveredConsole> get discoveredConsoles => _discoveredConsoles;
  bool get isDiscovering => _isDiscovering;
  String? get lastError => _lastError;

  /// Start auto-discovery with multiple strategies
  Future<List<DiscoveredConsole>> discover({
    int timeoutSeconds = _discoveryTimeoutSeconds,
    bool useMdns = true,
    bool useUdpBroadcast = true,
    bool useIpRange = true,
  }) async {
    if (_isDiscovering) return _discoveredConsoles;

    _isDiscovering = true;
    _lastError = null;
    _discoveredConsoles = [];
    notifyListeners();

    try {
      final futures = <Future<List<DiscoveredConsole>>>[];

      if (useMdns) {
        futures.add(_discoverViaMdns(timeoutSeconds));
      }

      if (useUdpBroadcast) {
        futures.add(_discoverViaUdpBroadcast(timeoutSeconds));
      }

      if (useIpRange) {
        futures.add(_discoverViaIpRange(timeoutSeconds));
      }

      final results = await Future.wait(futures, eagerError: false);
      
      final allConsoles = <DiscoveredConsole>[];
      for (var result in results) {
        allConsoles.addAll(result);
      }

      // Remove duplicates (same IP)
      final uniqueConsoles = <String, DiscoveredConsole>{};
      for (var console in allConsoles) {
        if (!uniqueConsoles.containsKey(console.ipAddress)) {
          uniqueConsoles[console.ipAddress] = console;
        }
      }

      _discoveredConsoles = uniqueConsoles.values.toList();
    } catch (e) {
      _lastError = 'Discovery error: $e';
      if (kDebugMode) print(_lastError);
    } finally {
      _isDiscovering = false;
      notifyListeners();
    }

    return _discoveredConsoles;
  }

  /// Strategy 1: mDNS Discovery
  Future<List<DiscoveredConsole>> _discoverViaMdns(int timeoutSeconds) async {
    try {
      // Using mdns_dart package to find _grandma._tcp.local services
      // Implementation depends on mdns_dart API
      // For now, returning empty - will be implemented with actual mDNS scanning
      if (kDebugMode) print('mDNS discovery initiated...');
      
      // TODO: Integrate mdns_dart package
      // const mdns = MDNSDiscovery();
      // final services = await mdns.discover(_mdnsServiceName);
      
      return [];
    } catch (e) {
      if (kDebugMode) print('mDNS discovery failed: $e');
      return [];
    }
  }

  /// Strategy 2: UDP Broadcast Discovery
  Future<List<DiscoveredConsole>> _discoverViaUdpBroadcast(
      int timeoutSeconds) async {
    try {
      final consoles = <DiscoveredConsole>[];
      final broadcastAddress = await _getBroadcastAddress();

      if (broadcastAddress == null) {
        return consoles;
      }

      // Send UDP broadcast packet
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final discoveryPacket = _buildDiscoveryPacket();
      socket.send(discoveryPacket, InternetAddress(broadcastAddress), _oscPort);

      // Listen for responses
      socket.listen(
        (event) {
          if (event == RawSocketEvent.read) {
            final datagram = socket.receive();
            if (datagram != null) {
              final console = _parseConsoleResponse(
                datagram.data,
                datagram.address.address,
              );
              if (console != null) {
                consoles.add(console);
              }
            }
          }
        },
        onError: (e) {
          if (kDebugMode) print('UDP discovery error: $e');
        },
      );

      // Wait and then close
      await Future.delayed(Duration(seconds: timeoutSeconds));
      socket.close();

      return consoles;
    } catch (e) {
      if (kDebugMode) print('UDP broadcast discovery failed: $e');
      return [];
    }
  }

  /// Strategy 3: IP Range Scanning (Fallback)
  Future<List<DiscoveredConsole>> _discoverViaIpRange(int timeoutSeconds) async {
    try {
      final consoles = <DiscoveredConsole>[];
      final localIp = await _networkInfo.getWifiIP();

      if (localIp == null) {
        return consoles;
      }

      // Get subnet (assuming /24)
      final parts = localIp.split('.');
      final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

      // Scan common console IPs (1-254)
      final futures = <Future<void>>[];

      for (int i = 1; i <= 254; i++) {
        futures.add(
          _checkConsoleAtIp('$subnet.$i', timeoutSeconds)
              .then((console) {
            if (console != null) {
              consoles.add(console);
            }
          }).catchError((_) => null),
        );
      }

      // Limit concurrent connections
      for (var batch in _batches(futures, 10)) {
        await Future.wait(batch);
      }

      return consoles;
    } catch (e) {
      if (kDebugMode) print('IP range discovery failed: $e');
      return [];
    }
  }

  /// Check if console exists at specific IP
  Future<DiscoveredConsole?> _checkConsoleAtIp(
      String ip, int timeoutSeconds) async {
    try {
      final socket = await Socket.connect(ip, _oscPort,
          timeout: Duration(seconds: timeoutSeconds));

      // Send discovery probe
      final probe = _buildDiscoveryPacket();
      socket.add(probe);

      // Wait for response
      final response = await socket.first.timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => <int>[],
      );

      socket.close();

      if (response.isNotEmpty) {
        return _parseConsoleResponse(response, ip);
      }
    } catch (e) {
      // Silent fail for IP scanning
    }
    return null;
  }

  /// Get local network broadcast address
  Future<String?> _getBroadcastAddress() async {
    try {
      final wifi = await _networkInfo.getWifiIP();
      if (wifi == null) return null;

      final parts = wifi.split('.');
      return '${parts[0]}.${parts[1]}.${parts[2]}.255';
    } catch (e) {
      return null;
    }
  }

  /// Build OSC discovery packet
  List<int> _buildDiscoveryPacket() {
    // Simple OSC packet: /discover
    // OSC format: address + null padding + type tag + data
    final address = '/discover\u0000\u0000\u0000\u0000';
    final typeTag = ',s\u0000\u0000';
    final data = 'GrandMA3\u0000\u0000\u0000\u0000';

    return utf8.encode(address + typeTag + data);
  }

  /// Parse console response from discovery packet
  DiscoveredConsole? _parseConsoleResponse(List<int> data, String ip) {
    try {
      // Parse OSC response: hostname and version
      final response = String.fromCharCodes(data);
      
      // Extract hostname and version (simplified parsing)
      // In production, proper OSC parsing would be needed
      final hostname = 'GrandMA3';
      final version = '3.0'; // Default

      return DiscoveredConsole(
        hostname: hostname,
        ipAddress: ip,
        port: _oscPort,
        version: version,
        discoveredAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Batch helper for concurrent operations
  List<List<T>> _batches<T>(List<T> items, int batchSize) {
    final batches = <List<T>>[];
    for (int i = 0; i < items.length; i += batchSize) {
      batches.add(items.sublist(i, 
          i + batchSize > items.length ? items.length : i + batchSize));
    }
    return batches;
  }

  /// Clear discovered consoles
  void clearDiscovered() {
    _discoveredConsoles = [];
    notifyListeners();
  }
}
