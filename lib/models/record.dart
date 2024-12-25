class Record {
  final int? id;
  final String name;
  final String type; // income or expense
  final double value;
  final String date;

  Record({
    this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'date': date,
    };
  }

  static Record fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      value: map['value'],
      date: map['date'],
    );
  }
}
