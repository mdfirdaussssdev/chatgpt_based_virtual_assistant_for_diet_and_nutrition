import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudUserLatestFoodNutritionQuery {
  final String documentId;
  final String ownerUserId;
  final String foodNutritionQueryResult;

  CloudUserLatestFoodNutritionQuery.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        foodNutritionQueryResult =
            snapshot.data()[foodNutritionQueryResultFieldName] as String;
}
