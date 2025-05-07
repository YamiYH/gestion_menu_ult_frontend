import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Date.dart'; // Asegúrate que la ruta es correcta

import '../../widgets/Button.dart'; // Asegúrate que la ruta es correcta

class MenuPropuesta extends StatefulWidget {
  @override
  State<MenuPropuesta> createState() => _MenuPropuestaState();
}

class _MenuPropuestaState extends State<MenuPropuesta> {
  final List<String> ensaladas = [
    'Seleccionar Ensaladas y Vegetales',
    'Ensalada de acelga',
    'Ensalada de aguacate'
  ];
  final List<String> sopas = [
    'Seleccionar Sopas, Caldos y Frijoles',
    'Ajiaco',
    'Sopa de chícharo c/  fideos'
  ];
  final List<String> arroces = [
    'Seleccionar Arroces y Pastas',
    'Arroz blanco',
    'Arroz congrís'
  ];
  final List<String> huevos = [
    'Seleccionar Huevos',
    'Huevo frito',
    'Huevo hervido'
  ];
  final List<String> carnes = [
    'Seleccionar Carnes y Embutidos',
    'Aporreado de tasajo',
    'Aporreado de pollo '
  ];
  final List<String> pescados = [
    'Seleccionar Pescados',
    'Enchilado   de  pescado',
    'Pescado frito'
  ];
  final List<String> harinas = [
    'Seleccionar Harinas',
    'Harina de maíz c/sal',
    'Harina de maíz en dulce'
  ];
  final List<String> croquetas = [
    'Seleccionar Croquetas y Frituras',
    'Croquetas',
    'Masa para croquetas fritas'
  ];
  final List<String> viandas = [
    'Seleccionar Viandas',
    'Papa  hervida',
    'Papa frita '
  ];
  final List<String> panes = [
    'Seleccionar Panes',
    'Pan  con  huevo  frito',
    'Pan con tomate'
  ];
  final List<String> frutas = [
    'Seleccionar Frutas, Jugos y Dulces',
    'Tajadas de  fruta bomba',
    'Tajadas de mango'
  ];
  final List<String> salsas = [
    'Seleccionar Salsas y Lácteos',
    'Salsa criolla',
    'Yogurt natural'
  ];

  String? selectedEnsaladasEstudiantes;
  String? selectedSopasEstudiantes;
  String? selectedArrocesEstudiantes;
  String? selectedHuevosEstudiantes;
  String? selectedCarnesEstudiantes;
  String? selectedPescadosEstudiantes;
  String? selectedHarinasEstudiantes;
  String? selectedCroquetasEstudiantes;
  String? selectedViandasEstudiantes;
  String? selectedPanesEstudiantes;
  String? selectedFrutasEstudiantes;
  String? selectedSalsasEstudiantes;

  String? selectedEnsaladasTrabajadores;
  String? selectedSopasTrabajadores;
  String? selectedArrocesTrabajadores;
  String? selectedHuevosTrabajadores;
  String? selectedCarnesTrabajadores;
  String? selectedPescadosTrabajadores;
  String? selectedHarinasTrabajadores;
  String? selectedCroquetasTrabajadores;
  String? selectedViandasTrabajadores;
  String? selectedPanesTrabajadores;
  String? selectedFrutasTrabajadores;
  String? selectedSalsasTrabajadores;

  String? selectedMealType = 'Almuerzo';

  bool isEstudiantesEnabled = true;
  bool isTrabajadoresEnabled = true;

  bool _isProposalConfirmed = false;
  DateTime? selectedDate = DateTime.now().add(Duration(days: 1));

  Future<void> _showConfirmationDialog(bool isMobile) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isMobile = MediaQuery.of(context).size.width < 600;
        return AlertDialog(
          title: Center(child: Text('Confirmar Propuesta')),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('¿Está seguro de que desea proponer este menú?'),
                Text('Una vez propuesto, no podrá editarlo.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(
                    color: Colors.black87, fontSize: isMobile ? 14 : 18),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text(
                'Confirmar',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 18),
              ),
              onPressed: () {
                print('Propuesta confirmada');
                setState(() {
                  _isProposalConfirmed = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Propuesta enviada (simulado)')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Propuestas de Menú',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(height: 15),
              isMobile
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FoodDropDown(selectedMealType, (newValue) {
                              setState(() {
                                selectedMealType = newValue;
                              });
                            }, isMobile),
                            SizedBox(width: isMobile ? 10 : 20),
                            DateWidget(
                              selectedDate: selectedDate,
                              onDateSelected: (date) {
                                setState(() {
                                  selectedDate = date;
                                });
                              },
                              size: isMobile
                                  ? MediaQuery.of(context).size.width * 0.45
                                  : MediaQuery.of(context).size.width * 0.15,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Button(
                          onPressed: _isProposalConfirmed
                              ? null
                              : () {
                                  _showConfirmationDialog(isMobile);
                                },
                          text: _isProposalConfirmed
                              ? 'Propuesta Enviada'
                              : 'Proponer',
                          size: Size(isMobile ? 320 : 170, isMobile ? 60 : 50),
                          colorButton:
                              _isProposalConfirmed ? Colors.grey : null,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FoodDropDown(selectedMealType, (newValue) {
                          setState(() {
                            selectedMealType = newValue;
                          });
                        }, isMobile),
                        SizedBox(width: isMobile ? 10 : 20),
                        DateWidget(
                          selectedDate: selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          size: isMobile
                              ? MediaQuery.of(context).size.width * 0.4
                              : MediaQuery.of(context).size.width * 0.15,
                        ),
                        SizedBox(width: isMobile ? 10 : 20),
                        Button(
                          onPressed: _isProposalConfirmed
                              ? null
                              : () {
                                  _showConfirmationDialog(isMobile);
                                },
                          text: _isProposalConfirmed ? 'Propuesto' : 'Proponer',
                          size: Size(isMobile ? 320 : 180, isMobile ? 60 : 50),
                          colorButton:
                              _isProposalConfirmed ? Colors.grey : null,
                        ),
                      ],
                    ),
              SizedBox(height: isMobile ? 10 : 40, width: isMobile ? 0 : 20),
              isMobile
                  ? ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: Cards(isMobile))
                  : Row(children: Cards(isMobile)),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> Cards(bool isMobile) {
    return [
      Expanded(
        child: MenuCard(
          isMobile,
          'Menú Estudiantes',
          true,
          isEnabledByCheckbox: isEstudiantesEnabled,
          isProposalConfirmed: _isProposalConfirmed,
          onCheckboxChanged: (value) {
            if (!_isProposalConfirmed) {
              setState(() {
                isEstudiantesEnabled = value!;
              });
            }
          },
        ),
      ),
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 10 : 0),
      Expanded(
        child: MenuCard(isMobile, 'Menú Trabajadores', false,
            isEnabledByCheckbox: isTrabajadoresEnabled,
            isProposalConfirmed: _isProposalConfirmed,
            onCheckboxChanged: (value) {
          if (!_isProposalConfirmed) {
            setState(() {
              isTrabajadoresEnabled = value!;
            });
          }
        }),
      ),
    ];
  }

  Widget MenuCard(bool isMobile, String title, bool isEstudiantes,
      {required bool isEnabledByCheckbox,
      required bool isProposalConfirmed,
      required Function(bool?) onCheckboxChanged}) {
    final bool areDropdownsEnabled =
        !isProposalConfirmed && isEnabledByCheckbox;

    final bool isCheckboxEnabled = !isProposalConfirmed;

    return Opacity(
      opacity: isProposalConfirmed ? 0.5 : 1.0,
      child: AbsorbPointer(
        absorbing: isProposalConfirmed,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: isMobile ? null : MediaQuery.of(context).size.width * 0.3,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                    Checkbox(
                      activeColor: Colors.red,
                      value: isEnabledByCheckbox,
                      onChanged: isCheckboxEnabled ? onCheckboxChanged : null,
                    ),
                  ],
                ),
                Divider(),
                DropdownSelector(
                  label: 'Ensaladas y vegetales',
                  items: ensaladas,
                  value: isEstudiantes
                      ? selectedEnsaladasEstudiantes
                      : selectedEnsaladasTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedEnsaladasEstudiantes = value;
                            else
                              selectedEnsaladasTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Sopas, caldos y frijoles',
                  items: sopas,
                  value: isEstudiantes
                      ? selectedSopasEstudiantes
                      : selectedSopasTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes) {
                              selectedSopasEstudiantes = value;
                            } else {
                              selectedSopasTrabajadores = value;
                            }
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Arroces y pastas',
                  items: arroces,
                  value: isEstudiantes
                      ? selectedArrocesEstudiantes
                      : selectedArrocesTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedArrocesEstudiantes = value;
                            else
                              selectedArrocesTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Huevos',
                  items: huevos,
                  value: isEstudiantes
                      ? selectedHuevosEstudiantes
                      : selectedHuevosTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedHuevosEstudiantes = value;
                            else
                              selectedHuevosTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Carnes y embutidos',
                  items: carnes,
                  value: isEstudiantes
                      ? selectedCarnesEstudiantes
                      : selectedCarnesTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedCarnesEstudiantes = value;
                            else
                              selectedCarnesTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Pescados',
                  items: pescados,
                  value: isEstudiantes
                      ? selectedPescadosEstudiantes
                      : selectedPescadosTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedPescadosEstudiantes = value;
                            else
                              selectedPescadosTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Harinas',
                  items: harinas,
                  value: isEstudiantes
                      ? selectedHarinasEstudiantes
                      : selectedHarinasTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedHarinasEstudiantes = value;
                            else
                              selectedHarinasTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Croquetas y frituras',
                  items: croquetas,
                  value: isEstudiantes
                      ? selectedCroquetasEstudiantes
                      : selectedCroquetasTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedCroquetasEstudiantes = value;
                            else
                              selectedCroquetasTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Viandas',
                  items: viandas,
                  value: isEstudiantes
                      ? selectedViandasEstudiantes
                      : selectedViandasTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedViandasEstudiantes = value;
                            else
                              selectedViandasTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Panes',
                  items: panes,
                  value: isEstudiantes
                      ? selectedPanesEstudiantes
                      : selectedPanesTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedPanesEstudiantes = value;
                            else
                              selectedPanesTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Frutas, Jugos y Dulces',
                  items: frutas,
                  value: isEstudiantes
                      ? selectedFrutasEstudiantes
                      : selectedFrutasTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedFrutasEstudiantes = value;
                            else
                              selectedFrutasTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
                DropdownSelector(
                  label: 'Salsas y Lácteos',
                  items: salsas,
                  value: isEstudiantes
                      ? selectedSalsasEstudiantes
                      : selectedSalsasTrabajadores,
                  onChanged: areDropdownsEnabled
                      ? (value) {
                          setState(() {
                            if (isEstudiantes)
                              selectedSalsasEstudiantes = value;
                            else
                              selectedSalsasTrabajadores = value;
                          });
                        }
                      : null,
                  isEnabled: areDropdownsEnabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownSelector extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final void Function(String?)? onChanged;
  final bool? isEnabled;

  const DropdownSelector({
    Key? key,
    required this.label,
    required this.items,
    this.value,
    required this.onChanged,
    required this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !(isEnabled ?? true),
      child: Opacity(
        opacity: (isEnabled ?? true) ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            DropdownButton<String>(
              value: value,
              hint: Text('$label'),
              isExpanded: true,
              onChanged: onChanged,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              iconDisabledColor: Colors.grey,
              iconEnabledColor: Colors.red[900],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

Widget FoodDropDown(
    String? selectedMealType, Function(String?) onChanged, isMobile) {
  return SizedBox(
    width: isMobile ? 160 : 200,
    height: isMobile ? 55 : 50,
    child: InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMealType,
          onChanged: onChanged,
          items: ['Desayuno', 'Almuerzo', 'Comida', 'Merienda']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: 18)),
            );
          }).toList(),
          icon: Icon(Icons.arrow_drop_down_circle, color: Colors.red[900]),
          dropdownColor: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          isExpanded: false,
        ),
      ),
    ),
  );
}
