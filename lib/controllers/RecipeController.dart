// lib/controllers/user/UserController.dart

import '../models/Recipe.dart';
import 'BaseController.dart';

class RecipeController extends BaseController {
  @override
  final String endPoint = '/api/v1/recipes';

  // --- MÉTODO PARA OBTENER LA LISTA DE RECETAS ---
  Future<List<Recipe>> fetchRecipe({Map<String, String>? filters}) async {
    Map<String, String> queryParams = {
      'pageNo': super.currentPage.toString(),
      'pageSize': super.pageSize.toString(),
      'sortType': 'asc',
      'sortBy': 'name',
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
        List<dynamic> recipeListJson = responseData['content'];
        super.totalPages = responseData['totalPages'] ?? 1;
        super.currentPage = responseData['number'] ?? 0;
        return recipeListJson.map((data) => Recipe.fromJson(data)).toList();
      } else {
        throw Exception("Formato de respuesta de recetas inesperado.");
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA CREAR UNA RECETA (SIMPLIFICADO) ---
  Future<Recipe> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      // Llama al método POST genérico
      final responseData = await super.post(endPoint, body: recipeData);
      return Recipe.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ACTUALIZAR UNA RECETA (SIMPLIFICADO) ---
  Future<Recipe> updateUser(Map<String, dynamic> recipeData) async {
    try {
      // Llama al método PUT genérico
      final responseData = await super.put(endPoint, body: recipeData);
      return Recipe.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ELIMINAR UNA RECETA (SIMPLIFICADO) ---
  Future<void> deleteRecipe(String id) async {
    try {
      // Llama al método DELETE genérico, construyendo la ruta completa del recurso
      await super.delete('$endPoint/$id');
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO CON ENDPOINT DIFERENTE ---
  Future<List<String>> fetchCategories() async {
    try {
      final responseData =
          await super.get('/api/v1/metadata/recipe/categories');
      final categoriesList =
          List<String>.from((responseData as List).map((t) => t.toString()));
      return categoriesList;
    } catch (e) {
      rethrow;
    }
  }
}
