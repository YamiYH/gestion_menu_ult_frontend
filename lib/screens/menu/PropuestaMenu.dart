import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Date.dart';

import '../../widgets/Button.dart';
import '../../widgets/DynamicButton.dart';

class MenuPropuesta extends StatefulWidget {
  @override
  State<MenuPropuesta> createState() => _MenuPropuestaState();
}

class _MenuPropuestaState extends State<MenuPropuesta> {
  // Datos simulados de opciones para los dropdowns
  final List<String> ensaladas = ['Ensalada de acelga', 'Ensalada de aguacate'];
  final List<String> sopas = ['Ajiaco', 'Sopa de chícharo c/  fideos'];
  final List<String> arroces = ['Arroz blanco', 'Arroz congrís'];
  final List<String> huevos = ['Huevo frito', 'Huevo hervido'];
  final List<String> carnes = ['Aporreado de tasajo', 'Aporreado de pollo '];
  final List<String> pescados = ['Enchilado   de  pescado', 'Pescado frito'];
  final List<String> harinas = [
    'Harina de maíz c/sal',
    'Harina de maíz en dulce'
  ];
  final List<String> croquetas = ['Croquetas', 'Masa para croquetas fritas'];
  final List<String> viandas = ['Papa  hervida', 'Papa frita '];
  final List<String> panes = ['Pan  con  huevo  frito ', 'Pan con tomate'];
  final List<String> frutas = ['Tajadas de  fruta bomba', 'Tajadas de mango'];
  final List<String> salsas = [];

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

  // Estado para almacenar las selecciones del menú de profesores
  String? selectedEnsaladasProfesores;
  String? selectedSopasProfesores;
  String? selectedArrocesProfesores;
  String? selectedHuevosProfesores;
  String? selectedCarnesProfesores;
  String? selectedPescadosProfesores;
  String? selectedHarinasProfesores;
  String? selectedCroquetasProfesores;
  String? selectedViandasProfesores;

  String? selectedMealType = 'Almuerzo';

  // Fecha seleccionada
  DateTime? selectedDate = DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(title: 'Propuestas de Menú'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              SizedBox(height: 15),
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
                    isMobile: isMobile,
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    width1: isMobile
                        ? MediaQuery.of(context).size.width * 0.4
                        : MediaQuery.of(context).size.width * 0.15,
                  ),
                  SizedBox(width: isMobile ? 10 : 20),
                  Button(
                    icon: Icons.search,
                    text: 'Buscar',
                    onPressed: () {},
                  ),
                  SizedBox(width: isMobile ? 10 : 20),
                  DynamicButton(
                    onPressed: () {},
                    text: 'Aprobar',
                    icon: Icons.done,
                    colorButton: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 10 : 40, width: isMobile ? 10 : 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: MenuCard(isMobile, 'Menú Estudiantes', true),
                  ),
                  SizedBox(width: isMobile ? 10 : 20),
                  Expanded(
                    child: MenuCard(isMobile, 'Menú Trabajadores', false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para el menú expandido
  Widget MenuCard(bool isMobile, String title, bool isEstudiantes) {
    return Card(
      color: Colors.white,
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
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
              ),
            ),
            Divider(),
            DropdownSelector(
              label: 'Ensaladas y vegetales',
              items: ensaladas,
              value: isEstudiantes
                  ? selectedEnsaladasEstudiantes
                  : selectedEnsaladasProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedEnsaladasEstudiantes = value;
                  } else {
                    selectedEnsaladasProfesores = value;
                  }
                });
              },
            ),
            DropdownSelector(
              label: 'Sopas, caldos y frijoles',
              items: sopas,
              value: isEstudiantes
                  ? selectedSopasEstudiantes
                  : selectedSopasProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedSopasEstudiantes = value;
                  } else {
                    selectedSopasProfesores = value;
                  }
                });
              },
            ),
            DropdownSelector(
              label: 'Arroces y pastas',
              items: arroces,
              value: isEstudiantes
                  ? selectedArrocesEstudiantes
                  : selectedArrocesProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedArrocesEstudiantes = value;
                  } else {
                    selectedArrocesProfesores = value;
                  }
                });
              },
            ),
            DropdownSelector(
              label: 'Huevos',
              items: huevos,
              value: isEstudiantes
                  ? selectedHuevosEstudiantes
                  : selectedHuevosProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedHuevosEstudiantes = value;
                  } else {
                    selectedHuevosProfesores = value;
                  }
                });
              },
            ),
            DropdownSelector(
              label: 'Carnes y embutidos',
              items: carnes,
              value: isEstudiantes
                  ? selectedCarnesEstudiantes
                  : selectedCarnesProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedCarnesEstudiantes = value;
                  } else {
                    selectedCarnesProfesores = value;
                  }
                });
              },
            ),
            DropdownSelector(
              label: 'Pescados',
              items: pescados,
              value: isEstudiantes
                  ? selectedPescadosEstudiantes
                  : selectedPescadosProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedPescadosEstudiantes = value;
                  } else {
                    selectedPescadosProfesores = value;
                  }
                });
              },
            ),
            DropdownSelector(
              label: 'Harinas',
              items: harinas,
              value: isEstudiantes
                  ? selectedHarinasEstudiantes
                  : selectedHarinasProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedHarinasEstudiantes = value;
                  } else {
                    selectedHarinasProfesores = value;
                  }
                });
              },
            ),
            DropdownSelector(
              label: 'Croquetas y frituras',
              items: croquetas,
              value: isEstudiantes
                  ? selectedCroquetasEstudiantes
                  : selectedCroquetasProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedCroquetasEstudiantes = value;
                  } else {
                    selectedCroquetasProfesores = value;
                  }
                });
              },
            ),
            DropdownSelector(
              label: 'Viandas',
              items: viandas,
              value: isEstudiantes
                  ? selectedViandasEstudiantes
                  : selectedViandasProfesores,
              onChanged: (value) {
                setState(() {
                  if (isEstudiantes) {
                    selectedViandasEstudiantes = value;
                  } else {
                    selectedViandasProfesores = value;
                  }
                });
              },
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
  final Function(String?) onChanged;

  const DropdownSelector({
    Key? key,
    required this.label,
    required this.items,
    this.value,
    required this.onChanged,
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
    width: isMobile ? 150 : 200,
    height: isMobile ? 65 : 50,
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
