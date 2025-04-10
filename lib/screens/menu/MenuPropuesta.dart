import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Date.dart';

import '../../widgets/DynamicButton.dart';

class MenuPropuesta extends StatefulWidget {
  @override
  State<MenuPropuesta> createState() => _MenuPropuestaState();
}

class _MenuPropuestaState extends State<MenuPropuesta> {
  // Datos simulados de opciones para los dropdowns
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

  // Estado para almacenar las selecciones del menú de estudiantes
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

  // Estado para almacenar las selecciones del menú de profesores
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

  // Estado para habilitar/deshabilitar las tarjetas
  bool isEstudiantesEnabled = true;
  bool isTrabajadoresEnabled = true;

  // Fecha seleccionada
  DateTime? selectedDate = DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Propuestas de Menú',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 60),
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
                        DynamicButton(
                          onPressed: () {},
                          text: 'Aprobar',
                          icon: Icons.done,
                          colorButton: Colors.green,
                          size: Size(isMobile ? 320 : 160, isMobile ? 60 : 50),
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
                        DynamicButton(
                          onPressed: () {},
                          text: 'Aprobar',
                          icon: Icons.done,
                          colorButton: Colors.green,
                          size: Size(isMobile ? 350 : 160, isMobile ? 60 : 50),
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
          isEnabled: isEstudiantesEnabled,
          onCheckboxChanged: (value) {
            setState(() {
              isEstudiantesEnabled = value!;
            });
          },
        ),
      ),
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 10 : 0),
      Expanded(
        child: MenuCard(isMobile, 'Menú Trabajadores', false,
            isEnabled: isTrabajadoresEnabled, onCheckboxChanged: (value) {
          setState(() {
            isTrabajadoresEnabled = value!;
          });
        }),
      ),
    ];
  }

  // Widget para el menú expandido
  Widget MenuCard(bool isMobile, String title, bool isEstudiantes,
      {required bool isEnabled, required Function(bool?) onCheckboxChanged}) {
    return Card(
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
                  value: isEnabled,
                  onChanged: onCheckboxChanged,
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
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedEnsaladasEstudiantes = value;
                        } else {
                          selectedEnsaladasTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Sopas, caldos y frijoles',
              items: sopas,
              value: isEstudiantes
                  ? selectedSopasEstudiantes
                  : selectedSopasTrabajadores,
              onChanged: isEnabled
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
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Arroces y pastas',
              items: arroces,
              value: isEstudiantes
                  ? selectedArrocesEstudiantes
                  : selectedArrocesTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedArrocesEstudiantes = value;
                        } else {
                          selectedArrocesTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Huevos',
              items: huevos,
              value: isEstudiantes
                  ? selectedHuevosEstudiantes
                  : selectedHuevosTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedHuevosEstudiantes = value;
                        } else {
                          selectedHuevosTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Carnes y embutidos',
              items: carnes,
              value: isEstudiantes
                  ? selectedCarnesEstudiantes
                  : selectedCarnesTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedCarnesEstudiantes = value;
                        } else {
                          selectedCarnesTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Pescados',
              items: pescados,
              value: isEstudiantes
                  ? selectedPescadosEstudiantes
                  : selectedPescadosTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedPescadosEstudiantes = value;
                        } else {
                          selectedPescadosTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Harinas',
              items: harinas,
              value: isEstudiantes
                  ? selectedHarinasEstudiantes
                  : selectedHarinasTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedHarinasEstudiantes = value;
                        } else {
                          selectedHarinasTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Croquetas y frituras',
              items: croquetas,
              value: isEstudiantes
                  ? selectedCroquetasEstudiantes
                  : selectedCroquetasTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedCroquetasEstudiantes = value;
                        } else {
                          selectedCroquetasTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Viandas',
              items: viandas,
              value: isEstudiantes
                  ? selectedViandasEstudiantes
                  : selectedViandasTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedViandasEstudiantes = value;
                        } else {
                          selectedViandasTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Panes',
              items: panes,
              value: isEstudiantes
                  ? selectedPanesEstudiantes
                  : selectedPanesTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedPanesEstudiantes = value;
                        } else {
                          selectedPanesTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Frutas, Jugos y Dulces',
              items: frutas,
              value: isEstudiantes
                  ? selectedFrutasEstudiantes
                  : selectedFrutasTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedFrutasEstudiantes = value;
                        } else {
                          selectedFrutasTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
            DropdownSelector(
              label: 'Salsas y Lácteos',
              items: salsas,
              value: isEstudiantes
                  ? selectedSalsasEstudiantes
                  : selectedSalsasTrabajadores,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (isEstudiantes) {
                          selectedSalsasEstudiantes = value;
                        } else {
                          selectedSalsasTrabajadores = value;
                        }
                      });
                    }
                  : null,
              isEnabled: isEnabled,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para los dropdowns
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
    return Column(
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
        ),
        SizedBox(height: 10),
      ],
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
