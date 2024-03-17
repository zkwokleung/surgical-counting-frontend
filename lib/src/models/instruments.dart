class InstrumentStatus {
  int order;
  int qty;

  InstrumentStatus({this.order = -1, this.qty = 0});

  factory InstrumentStatus.fromJson(Map<String, dynamic> json) {
    return InstrumentStatus(
      order: json['order'],
      qty: json['qty'],
    );
  }
}
