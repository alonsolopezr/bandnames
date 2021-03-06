import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //listadio

  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('activeBands', this._handleActiveBands);
    super.initState();
  }

  //listener para recibir los datos de la coleccion para mostrar en Home
  void _handleActiveBands(dynamic payload) {
    print("--->Rellenando this.bands");

    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    print(this.bands.length.toString() + " elementos");
    // this
    //     .bands
    //     .addAll((bands as List).map((band) => Band.fromMap(band)).toList());
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('activeBands');
    socketService.socket.off('active-bands');
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BandNames",
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red[300],
                  ),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        print('direction: $direction');
        print('id: ${band.id}');
        socketService.socket.emit('del-band', {'id': band.id});
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(20.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Delete Band",
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () {
          print('Vamos a votar por. ' + band.name);
          // band.votes++;
          socketService.socket.emit('vote-band',
              {'id': band.id, 'name': band.name, 'votes': band.votes});
          //setState(() {});
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("New band name"),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                      child: Text("Add"),
                      elevation: 5,
                      textColor: Colors.blue,
                      onPressed: () => addBandToList(textController.text))
                ],
              ));
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text("New Band Name"),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Add"),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text("Dismiss"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          });
    }
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      //podemos agregarlo
      // this
      // .bands
      // .add(new Band(id: bands.length.toString(), name: name, votes: 0));
      //emitir: add-band
      SocketService socketService =
          Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
      //{name: name}
    }
    //setState(() {});
    Navigator.pop(context);
  }

  /// Show Ring graph .
  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    //asignamos al dataMap los data del Bands
    this.bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    List<Color> colorList = [
      Colors.blue[500],
      Colors.purple[500],
      Colors.brown[500],
      Colors.green[500],
      Colors.pink[500]
    ];
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: 200,
      child: PieChart(
        // dataMap: (this.bands as List).map((band) => Band.fromMap(band)).toList(),
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "Bands Votes",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          // legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
      ),
    );
    //return PieChart(dataMap: dataMap);
  }
}
