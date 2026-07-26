class Business {
  final int? id;
  final String name;
  final String colorHex; // couleur de l'onglet, ex: "#C9962C"

  Business({this.id, required this.name, required this.colorHex});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
      };

  factory Business.fromMap(Map<String, dynamic> map) => Business(
        id: map['id'] as int?,
        name: map['name'] as String,
        colorHex: map['colorHex'] as String,
      );
}
