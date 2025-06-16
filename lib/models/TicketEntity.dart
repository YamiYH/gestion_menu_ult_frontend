
///TicketResponse
class TicketEntityResponse {
  String campus;
  String date;
  String id;
  String menuType;
  List<String> recipes;
  String status;
  double totalPrice;
  String userFullName;

  TicketEntityResponse({
    required this.campus,
    required this.date,
    required this.id,
    required this.menuType,
    required this.recipes,
    required this.status,
    required this.totalPrice,
    required this.userFullName,
  });

  // Constructor desde JSON
  factory TicketEntityResponse.fromJson(Map<String, dynamic> json) {
    return TicketEntityResponse(
      campus: json['campus'] as String? ?? 'Sin Campus',
      date: json['date'] as String? ?? 'Sin Fecha',
      id: json['id'] as String? ?? 'Sin ID',
      menuType: json['menuType'] as String? ?? 'Sin Tipo de Menú',
      recipes: List<String>.from(json['recipes'] ?? []),
      status: json['status'] as String? ?? 'Sin Estado',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      userFullName: json['userFullName'] as String? ?? 'Sin Nombre de Usuario',
    );
  }
}

///TicketRequest
class TicketEntityRequest {
  String? campus;
  String? id;
  String? menu;
  String? qr;
  List<String>? recipes;
  String? status;
  double? totalPrice;
  String? user;

  TicketEntityRequest({
    this.campus,
    this.id,
    this.menu,
    this.qr,
    this.recipes,
    this.status,
    this.totalPrice,
    this.user,
  });

  //factory fromJson
  factory TicketEntityRequest.fromJson(Map<String, dynamic> json) {
    return TicketEntityRequest(
      campus: json['campus'] as String?,
      id: json['id'] as String?,
      menu: json['menu'] as String?,
      qr: json['qr'] as String?,
      recipes: (json['recipes'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      status: json['status'] as String?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      user: json['user'] as String?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'campus': campus,
      'id': id,
      'menu': menu,
      'qr': qr,
      'recipes': recipes,
      'status': status,
      'totalPrice': totalPrice,
      'user': user,
    };
  }
}