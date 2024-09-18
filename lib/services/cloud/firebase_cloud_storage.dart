import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_constants.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_latest_food_nutrition_query.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_latest_food_recipe_query.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCloudStorage {
  // name of collection is userDetails in Firebase Database
  final userDetails = FirebaseFirestore.instance.collection('userDetails');

  final userLatestFoodNutritionQuery =
      FirebaseFirestore.instance.collection('userLatestFoodNutritionQuery');

  final userLatestFoodRecipeQuery =
      FirebaseFirestore.instance.collection('userLatestFoodRecipeQuery');

// For userDetails

  Future<void> deleteUserDetails({required String documentId}) async {
    try {
      await userDetails.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteUserDetailsException();
    }
  }

  Future<void> updateUserDetails({
    required String documentId,
    required DateTime userDateOfBirth,
    required int userWeight,
    required int userHeight,
    required List<String> userDiseases,
    required String userGender,
    required String userGoal,
    required String userActivityLevel,
  }) async {
    try {
      await userDetails.doc(documentId).update({
        dobFieldName: Timestamp.fromDate(userDateOfBirth),
        weightFieldName: userWeight,
        heightFieldName: userHeight,
        diseasesFieldName: userDiseases,
        genderFieldName: userGender,
        goalFieldName: userGoal,
        activityLevelFieldName: userActivityLevel,
      });
    } catch (e) {
      throw CouldNotUpdateUserDetailsException();
    }
  }

  Future<CloudUserDetails> getUserDetails({required String ownerUserId}) async {
    try {
      final querySnapshot = await userDetails
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get();
      // Check if we have any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Extract the first document and convert it to CloudNote
        final userDoc = querySnapshot.docs.first;
        return CloudUserDetails.fromSnapshot(userDoc);
      } else {
        throw CouldNotGetUserDetailsException();
      }
    } catch (e) {
      throw CouldNotGetUserDetailsException();
    }
  }

  Future<void> createNewUserDetails({
    required String ownerUserId,
    required DateTime userDateOfBirth,
    required int userWeight,
    required int userHeight,
    required List<String> userDiseases,
    required String userGender,
    required String userGoal,
    required String userActivityLevel,
  }) async {
    try {
      await userDetails.add({
        ownerUserIdFieldName: ownerUserId,
        dobFieldName: userDateOfBirth,
        weightFieldName: userWeight,
        heightFieldName: userHeight,
        diseasesFieldName: userDiseases,
        genderFieldName: userGender,
        goalFieldName: userGoal,
        activityLevelFieldName: userActivityLevel,
      });
    } catch (e) {
      throw CouldNotCreateUserDetailsException();
    }
  }

// For userLatestFoodNutritionQuery

  Future<void> deleteUserFoodNutritionQuery(
      {required String documentId}) async {
    try {
      await userLatestFoodNutritionQuery.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteFoodNutritionQueryException();
    }
  }

  Future<void> updateUserFoodNutritionQuery({
    required String documentId,
    required String foodNutritionQueryResult,
  }) async {
    try {
      await userLatestFoodNutritionQuery.doc(documentId).update({
        foodNutritionQueryResultFieldName: foodNutritionQueryResult,
      });
    } catch (e) {
      throw CouldNotUpdateFoodNutritionQueryException();
    }
  }

  Future<CloudUserLatestFoodNutritionQuery> getUserFoodNutritionQueryDetails({
    required String ownerUserId,
  }) async {
    try {
      final querySnapshot = await userLatestFoodNutritionQuery
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get();
      // Check if we have any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Extract the first document and convert it to CloudNote
        final userDoc = querySnapshot.docs.first;
        return CloudUserLatestFoodNutritionQuery.fromSnapshot(userDoc);
      } else {
        throw CouldNotGetFoodNutritionQueryException();
      }
    } catch (e) {
      throw CouldNotGetFoodNutritionQueryException();
    }
  }

  Future<void> createNewUserFoodNutritionQuery({
    required String ownerUserId,
    required String foodNutritionQueryResult,
  }) async {
    try {
      final userDoc = await getUserFoodNutritionQueryDetails(
        ownerUserId: ownerUserId,
      );
      updateUserFoodNutritionQuery(
          documentId: userDoc.documentId,
          foodNutritionQueryResult: foodNutritionQueryResult);
    } on CouldNotGetFoodNutritionQueryException {
      await userLatestFoodNutritionQuery.add({
        ownerUserIdFieldName: ownerUserId,
        foodNutritionQueryResultFieldName: foodNutritionQueryResult
      });
    }
  }

// For userLatestFoodRecipeQuery
  Future<void> deleteUserFoodRecipeQuery({required String documentId}) async {
    try {
      await userLatestFoodRecipeQuery.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteFoodRecipeQueryException();
    }
  }

  Future<void> updateUserFoodRecipeQuery({
    required String documentId,
    required String imageUrl,
    required String title,
    required String reason,
    required List<String> ingredients,
    required List<String> instructions,
    required List<bool> checkedIngredients,
    required List<bool> checkedInstructions,
  }) async {
    try {
      await userLatestFoodRecipeQuery.doc(documentId).update({
        foodRecipeImageUrlFieldName: imageUrl,
        foodRecipeTitleFieldName: title,
        foodRecipeReasonFieldName: reason,
        foodRecipeIngredientsFieldName: ingredients,
        foodRecipeInstructionsFieldName: instructions,
        foodRecipeCheckedIngredientsFieldName: checkedIngredients,
        foodRecipeCheckedInstructionsFieldName: checkedInstructions,
      });
    } catch (e) {
      throw CouldNotUpdateFoodRecipeQueryException();
    }
  }

  Future<CloudUserLatestFoodRecipeQuery> getUserFoodRecipeQueryDetails({
    required String ownerUserId,
  }) async {
    try {
      final querySnapshot = await userLatestFoodRecipeQuery
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get();
      // Check if we have any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Extract the first document and convert it to CloudLatestFoodRecipeQuery
        final userDoc = querySnapshot.docs.first;
        return CloudUserLatestFoodRecipeQuery.fromSnapshot(userDoc);
      } else {
        throw CouldNotGetFoodRecipeQueryException();
      }
    } catch (e) {
      throw CouldNotGetFoodRecipeQueryException();
    }
  }

  Future<void> createNewUserFoodRecipeQuery({
    required String ownerUserId,
    required String imageUrl,
    required String title,
    required String reason,
    required List<String> ingredients,
    required List<String> instructions,
    required List<bool> checkedIngredients,
    required List<bool> checkedInstructions,
  }) async {
    try {
      final userDoc = await getUserFoodRecipeQueryDetails(
        ownerUserId: ownerUserId,
      );
      updateUserFoodRecipeQuery(
        documentId: userDoc.documentId,
        imageUrl: imageUrl,
        title: title,
        reason: reason,
        ingredients: ingredients,
        instructions: instructions,
        checkedIngredients: checkedIngredients,
        checkedInstructions: checkedInstructions,
      );
    } on CouldNotGetFoodRecipeQueryException {
      await userLatestFoodRecipeQuery.add({
        ownerUserIdFieldName: ownerUserId,
        foodRecipeImageUrlFieldName: imageUrl,
        foodRecipeTitleFieldName: title,
        foodRecipeReasonFieldName: reason,
        foodRecipeIngredientsFieldName: ingredients,
        foodRecipeInstructionsFieldName: instructions,
        foodRecipeCheckedIngredientsFieldName: checkedIngredients,
        foodRecipeCheckedInstructionsFieldName: checkedInstructions,
      });
    }
  }

  // ensures that only one instance of the
  // FirebaseCloudStorage class exists throughout the application.

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
