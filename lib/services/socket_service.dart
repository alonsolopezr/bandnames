import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket _socket;
  IO.Socket get socket => this._socket;

  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    String urlSocket = 'http://192.168.1.7:3000'; //tu ipv4

    this._socket = IO.io(
        urlSocket,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect()
            //  .setExtraHeaders({'foo': 'bar'}) // optional
            .build());

    // Estado Conectado
    this._socket.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      print('Conectado por Socket');
      notifyListeners();
    });

    // Estado Desconectado
    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      print('Desconectado del Socket Server');
      notifyListeners();
    });
    // Extra
    this._socket.on('nuevo_mensaje', (payload) {
      print('Msg extra ' +
          payload['administrador'].toString() +
          ' ' +
          payload['mensaje'].toString());
      //notifyListeners();
    });
  }
}
