import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../widgets/Button.dart'; // Asumo que este es tu AppBar personalizado
// Si tienes un widget de Botón personalizado, podrías importarlo:
// import 'package:gestion_menu_ult_frontend/widgets/Button.dart';

class Payment extends StatefulWidget {
  final String ticketId;
  final double amount;
  final String description;

  const Payment({
    super.key,
    this.ticketId = '',
    this.amount = 0.0,
    this.description = "Ticket de Almuerzo", // Valor por defecto
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool _isLoading = false; // Para mostrar un indicador de carga al procesar

  void _processPaymentWithEnzona() async {
    setState(() {
      _isLoading = true;
    });

    // Simulación del proceso de pago
    print('Iniciando pago con Enzona para el ticket: ${widget.ticketId}');
    print('Monto: ${widget.amount.toStringAsFixed(2)} CUP');

    // --- Aquí iría la lógica real para interactuar con la API de Enzona ---
    // 1. Obtener las credenciales de Enzona (Consumer Key, Secret, Merchant UUID, etc.)
    //    que el administrador configuró.
    // 2. Construir el objeto de pago con los detalles del ticket (productos, monto, descripción, etc.)
    //    final pay = Payments(
    //        merchant_uuid: "tu_merchant_uuid_configurado",
    //        description_payment: "Pago de ${widget.description} - ID: ${widget.ticketId}",
    //        currency: "CUP",
    //        lst_products: [Product(name: widget.description, quantity: 1, price: widget.amount, tax: 0).get_product()],
    //        merchant_op_id: widget.ticketId, // Podrías usar el ID del ticket aquí
    //        invoice_number: widget.ticketId.hashCode, // Un número de factura único
    //        return_url: "tu_url_de_retorno_configurada",
    //        cancel_url: "tu_url_de_cancelacion_configurada",
    //        terminal_id: "tu_terminal_id_configurado_opcional"
    //    );
    // 3. Llamar a `ebp.create_payments(payment: pay.get_payment())`.
    //    (donde 'ebp' es tu instancia de 'enzona_business_payment')
    // 4. Obtener el `link_confirm` de la respuesta.
    // 5. Redirigir al usuario a ese `link_confirm` usando `url_launcher` o un WebView.
    //    Ejemplo: if (await canLaunchUrl(Uri.parse(link_confirm))) {
    //               await launchUrl(Uri.parse(link_confirm), mode: LaunchMode.externalApplication);
    //             } else { throw 'No se pudo lanzar $link_confirm'; }

    // Por ahora, simulamos una demora y luego volvemos _isLoading a false.
    await Future.delayed(const Duration(seconds: 3));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redirigiendo a Enzona (simulado)...')),
    );
    // En un caso real, la app podría quedar en segundo plano mientras el usuario está en Enzona.
    // Deberías manejar el retorno a la app desde las URL_RETURN y URL_CANCEL.

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(title: 'Pago con Enzona'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Resumen de tu Pedido',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Descripción:', widget.description),
                    const SizedBox(height: 8),
                    _buildDetailRow('ID Ticket:', widget.ticketId),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total a Pagar:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text('${widget.amount.toStringAsFixed(2)} CUP',
                            style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Podrías poner un logo de Enzona aquí
                    Icon(Icons.payment_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Serás redirigido a la plataforma de Enzona para completar tu pago de forma segura.',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            (_isLoading)
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.red,
                  ))
                : Button(
                    size: Size(isMobile ? 200 : 260, 50),
                    onPressed: _processPaymentWithEnzona,
                    text: 'Pagar con Enzona',
                    icon: Icons.lock_open_outlined, // Ejemplo de ícono
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Volver a la pantalla anterior
              },
              child: Text(
                'Cancelar y Volver',
                style:
                    TextStyle(color: Colors.red, fontSize: isMobile ? 15 : 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
