import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('ESTADO DEL SERVIDOR: ${socketService.serverStatus}'),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          // Dart client
          print('mandando msg desde flutter');

          socketService.socket.emit('flutter-msg',
              {'nombre': 'flutter', 'mensaje': 'Hola desde flutter....'});
        },
      ),
    );
  }
}
