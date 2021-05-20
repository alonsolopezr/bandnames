class Band {
  //props
  String id;
  String name;
  int votes;

  //constructor
  Band({this.id, this.name, this.votes});

  //Factory constructor.. regresa una nueva instancia de clase
  //mapeando el obj de tipo definido
  factory Band.fromMap(Map<String, dynamic> obj) => Band(
        id: obj['id'],
        name: obj['name'],
        votes: obj['votes'],
      );
}
