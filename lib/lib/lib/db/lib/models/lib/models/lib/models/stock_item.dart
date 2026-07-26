class StockItem {
  final int? id;
  final int businessId;
  final String name;
  final int qty;
  final int unitPrice; // en FCFA

  StockItem({
    this.id,
    required this.businessId,
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  int get totalValue => qty * unitPrice;

  Map<String, dynamic> toMap() => {
        'id': id,
        'businessId': businessId,
        'name': name,
        'qty': qty,
        'unitPrice': unitPrice,
      };

  factory StockItem.fromMap(Map<String, dynamic> map) => StockItem(
        id: map['id'] as int?,
        businessId: map['businessId'] as int,
        name: map['name'] as String,
        qty: map['qty'] as int,
        unitPrice: map['unitPrice'] as int,
      );
}
