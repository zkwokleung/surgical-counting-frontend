class InstrumentStatus {
  int order;
  int qty;

  InstrumentStatus({this.order = -1, this.qty = 0});

  bool passed(Map<String, dynamic> expected) {
    return expected['order'] == order && expected['qty'] == qty;
  }

  factory InstrumentStatus.fromJson(Map<String, dynamic> json) {
    return InstrumentStatus(
      order: json['order'],
      qty: json['qty'],
    );
  }
}
