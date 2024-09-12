import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class CloudUserLatestFoodRecipeQuery {
  final String documentId;
  final String ownerUserId;
  final String imageUrl;
  final String title;
  final String reason;
  final List<String> ingredients;
  final List<String> instructions;
  final List<bool> checkedIngredients;
  final List<bool> checkedInstructions;

  CloudUserLatestFoodRecipeQuery.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        imageUrl = snapshot.data()[foodRecipeImageUrlFieldName] as String,
        title = snapshot.data()[foodRecipeTitleFieldName] as String,
        reason = snapshot.data()[foodRecipeReasonFieldName] as String,
        ingredients = List<String>.from(
            snapshot.data()[foodRecipeIngredientsFieldName] as List<dynamic>),
        instructions = List<String>.from(
            snapshot.data()[foodRecipeInstructionsFieldName] as List<dynamic>),
        checkedIngredients = List<bool>.from(snapshot
            .data()[foodRecipeCheckedIngredientsFieldName] as List<dynamic>),
        checkedInstructions = List<bool>.from(snapshot
            .data()[foodRecipeCheckedInstructionsFieldName] as List<dynamic>);
}
