import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  get serverStatus => this._serverStatus;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    // Dart client
    IO.Socket socket = IO.io('http://192.168.1.9:3000/', <dynamic, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      //socket.emit('msg', 'test');
    });
    socket.onDisconnect((_) {
      print('disconnect');
      this._serverStatus = ServerStatus.Offline;
    });
    // IO.Socket socket = IO.io('http://192.168.1.6:3000',
    //     OptionBuilder().setTransports(['websocket']).build());

    // socket.onConnect((_) {
    //   print('connect');
    //   //socket.emit('msg', 'test');
    // });

    // //When an event recieved from server, data is added to the stream
    // socket.onDisconnect((_) => print('disconnect'));
  }
}
