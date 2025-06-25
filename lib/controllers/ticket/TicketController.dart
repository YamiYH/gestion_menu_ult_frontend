import 'package:gestion_menu_ult_frontend/controllers/BaseController.dart';
import 'package:gestion_menu_ult_frontend/models/TicketEntity.dart';

class TicketController extends BaseController{
  @override
  String endPoint = '/api/v1/ticket';

  // --- MÉTODO PARA OBTENER LA LISTA DE TICKETS ---
  Future<List<TicketEntityResponse>> fetchTickets({Map<String, String>? filters}) async {
    Map<String, String> queryParams = {
      'pageNo': super.currentPage.toString(),
      'pageSize': super.pageSize.toString(),
      'sortType': 'asc',
      'sortBy': 'id',
    };

    if (filters != null) {
      queryParams.addAll(filters);
    }

    try {
      // Llama al método GET genérico de la clase padre
      final responseData = await super.get(endPoint, queryParams: queryParams);

      // Interpreta la respuesta JSON específica de este método
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('content')) {
        List<dynamic> ticketListJson = responseData['content'];
        super.totalPages = responseData['totalPages'] ?? 1;
        super.currentPage = responseData['number'] ?? 0;
        return ticketListJson.map((data) => TicketEntityResponse.fromJson(data)).toList();
      } else {
        throw Exception("Formato de respuesta de tickets inesperado.");
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA CREAR UN TICKET (SIMPLIFICADO) ---
  Future<TicketEntityResponse> createTicket(Map<String, dynamic> ticketData) async {
    try {
      // Llama al método POST genérico
      final responseData = await super.post(endPoint, body: ticketData);
      return TicketEntityResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ACTUALIZAR EL STATUS DE UN TICKET (SIMPLIFICADO) ---
  Future<TicketEntityResponse> changeTicketStatus(String id, String status) async {
    Map<String, String> queryParams = {'status': status};
    try {
      // Llama al método PUT genérico
      final responseData =
      await super.putWithParams('$endPoint/$id', queryParams: queryParams);
      return TicketEntityResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ELIMINAR UN TICKET (SIMPLIFICADO) ---
  Future<void> deleteTicket(String id) async {
    try {
      // Llama al método DELETE genérico, construyendo la ruta completa del recurso
      await super.delete('$endPoint/$id');
    } catch (e) {
      rethrow;
    }
  }
}