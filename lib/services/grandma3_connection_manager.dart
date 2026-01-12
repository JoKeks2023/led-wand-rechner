import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/dmx_models.dart';

/// Connection state machine
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  syncing,
  error,
  reconnecting,
}

/// GrandMA 3 OSC Connection Manager
/// Handles connection lifecycle, auto-reconnect, heartbeat
class GrandMA3ConnectionManager with ChangeNotifier {
  static const int _defaultHeartbeatInterval = 30; // seconds
  static const int _maxReconnectAttempts = 10;
  static const int _reconnectBaseDelay = 1000; // ms

  late GrandMA3Config _config;
  ConnectionState _state = ConnectionState.disconnected;
  
  int _reconnectAttempts = 0;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  DateTime? _lastHeartbeat;
  DateTime? _lastMessageReceived;
  String? _lastError;
  
  List<String> _messageQueue = [];
  bool _isProcessingQueue = false;

  ConnectionState get state => _state;
  GrandMA3Config get config => _config;
  DateTime? get lastHeartbeat => _lastHeartbeat;
  DateTime? get lastMessageReceived => _lastMessageReceived;
  String? get lastError => _lastError;
  bool get isConnected => _state == ConnectionState.connected;
  bool get isConnecting => _state == ConnectionState.connecting || 
                           _state == ConnectionState.reconnecting;

  GrandMA3ConnectionManager(GrandMA3Config config) : _config = config {
    _initializeConnection();
  }

  /// Initialize connection based on config
  void _initializeConnection() {
    if (_config.autoDiscoveryUsed ?? false) {
      // If from auto-discovery, can try immediate connection
      connect();
    }
  }

  /// Connect to GrandMA 3 console
  Future<void> connect() async {
    if (_state == ConnectionState.connecting || 
        _state == ConnectionState.connected) {
      return;
    }

    _setState(ConnectionState.connecting);
    _lastError = null;

    try {
      // Validate config
      if (_config.ipAddress.isEmpty || _config.oscPort == 0) {
        throw Exception('Invalid GrandMA3 configuration');
      }

      // Simulate connection (actual OSC connection would be here)
      // For now, this demonstrates the state machine
      await _performHandshake();
      
      _reconnectAttempts = 0;
      _setState(ConnectionState.connected);
      
      // Start heartbeat
      _startHeartbeat();
      
      if (kDebugMode) {
        print('Connected to GrandMA3 at ${_config.ipAddress}:${_config.oscPort}');
      }
    } catch (e) {
      _lastError = 'Connection failed: $e';
      _setState(ConnectionState.error);
      
      if (kDebugMode) print(_lastError);
      
      // Start reconnect
      _scheduleReconnect();
    }
  }

  /// Disconnect from console
  Future<void> disconnect() async {
    _stopHeartbeat();
    _cancelReconnect();
    _messageQueue.clear();
    
    _setState(ConnectionState.disconnected);
    _lastError = null;
    
    if (kDebugMode) print('Disconnected from GrandMA3');
  }

  /// Send OSC command to console
  Future<void> sendCommand(String command, {List<dynamic>? args}) async {
    if (!isConnected) {
      _lastError = 'Not connected to GrandMA3';
      return;
    }

    try {
      final oscMessage = _buildOscMessage(command, args);
      
      _messageQueue.add(command);
      await _sendOscMessage(oscMessage);
      
      _lastMessageReceived = DateTime.now();
    } catch (e) {
      _lastError = 'Send command failed: $e';
      _setState(ConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// Perform initial handshake with console
  Future<void> _performHandshake() async {
    // Send identification packet
    final helloMsg = _buildOscMessage('/hello', [
      _config.hostname ?? 'LED-Rechner',
      _config.oscPort,
      _config.version ?? '3.0',
    ]);
    
    await _sendOscMessage(helloMsg);
    
    // Wait for acknowledgment
    await Future.delayed(Duration(milliseconds: 500));
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    
    final interval = Duration(
      seconds: _config.heartbeatInterval ?? _defaultHeartbeatInterval,
    );
    
    _heartbeatTimer = Timer.periodic(interval, (_) async {
      if (isConnected) {
        try {
          await sendCommand('/ping');
          _lastHeartbeat = DateTime.now();
        } catch (e) {
          if (kDebugMode) print('Heartbeat failed: $e');
          _setState(ConnectionState.error);
          _scheduleReconnect();
        }
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Schedule reconnect attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= (_config.reconnectMaxAttempts ?? _maxReconnectAttempts)) {
      _setState(ConnectionState.error);
      _lastError = 'Max reconnect attempts reached';
      return;
    }

    _reconnectTimer?.cancel();
    
    // Exponential backoff: base delay * 2^attempt (capped)
    final delay = (_config.reconnectBaseDelay ?? _reconnectBaseDelay) *
        (1 << (_reconnectAttempts).clamp(0, 5));
    
    _setState(ConnectionState.reconnecting);
    
    if (kDebugMode) {
      print('Scheduling reconnect attempt ${_reconnectAttempts + 1} '
          'in ${delay}ms');
    }

    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      _reconnectAttempts++;
      connect();
    });
  }

  /// Cancel reconnect timer
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }

  /// Build OSC message
  String _buildOscMessage(String command, List<dynamic>? args) {
    // Simplified OSC message format
    // Real implementation would use proper OSC packet structure
    if (args == null || args.isEmpty) {
      return command;
    }
    return '$command ${args.join(' ')}';
  }

  /// Send OSC message (simplified)
  Future<void> _sendOscMessage(String message) async {
    // In production, this would use actual OSC protocol over UDP
    // For now, simulate network I/O
    await Future.delayed(Duration(milliseconds: 50));
    
    if (kDebugMode) print('OSC > $message');
  }

  /// Update connection configuration
  void updateConfig(GrandMA3Config newConfig) {
    final wasConnected = isConnected;
    
    _config = newConfig;
    
    if (wasConnected) {
      disconnect();
      connect();
    }
  }

  /// Get connection statistics
  Map<String, dynamic> getStats() {
    return {
      'state': _state.toString(),
      'reconnectAttempts': _reconnectAttempts,
      'lastHeartbeat': _lastHeartbeat?.toIso8601String(),
      'lastMessageReceived': _lastMessageReceived?.toIso8601String(),
      'messageQueueSize': _messageQueue.length,
      'isConnected': isConnected,
      'lastError': _lastError,
    };
  }

  /// Update state and notify
  void _setState(ConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Clean up resources
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
