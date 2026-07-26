enum EntryType { sale, expense }

class TransactionEntry {
  final int? id;
  final int businessId;
  final EntryType type;
  final String label;
  final int amount; // en FCFA
  final DateTime date;

  TransactionEntry({
    this.id,
    required this.businessId,
    required this.type,
    required this.label,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'businessId': businessId,
        'type': type == EntryType.sale ? 'sale' : 'expense',
        'label': label,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory TransactionEntry.fromMap(Map<String, dynamic> map) => TransactionEntry(
        id: map['id'] as int?,
        businessId: map['businessId'] as int,
        type: map['type'] == 'sale' ? EntryType.sale : EntryType.expense,
        label: map['label'] as String,
        amount: map['amount'] as int,
        date: DateTime.parse(map['date'] as String),
      );
}
