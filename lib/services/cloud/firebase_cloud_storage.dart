import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/intake_item.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_constants.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_intake.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_latest_food_nutrition_query.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_latest_food_recipe_query.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_daily_water_intake.dart';

class FirebaseCloudStorage {
  // name of collection is userDetails in Firebase Database
  final userDetails = FirebaseFirestore.instance.collection('userDetails');

  final userLatestFoodNutritionQuery =
      FirebaseFirestore.instance.collection('userLatestFoodNutritionQuery');

  final userLatestFoodRecipeQuery =
      FirebaseFirestore.instance.collection('userLatestFoodRecipeQuery');

  final userIntake = FirebaseFirestore.instance.collection('userIntake');

  final userDailyWaterIntake =
      FirebaseFirestore.instance.collection('userDailyWaterIntake');

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
    required String userId,
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

  Stream<CloudUserDetails> getUserDetailsStream({
    required String ownerUserId,
  }) {
    return userDetails
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final userDoc = snapshot.docs.first;
        return CloudUserDetails.fromSnapshot(userDoc);
      } else {
        throw CouldNotGetUserIntakeException();
      }
    });
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

// For userIntake
  Future<void> deleteUserIntake({required String documentId}) async {
    try {
      await userIntake.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteUserIntakeException();
    }
  }

  Future<void> updateUserIntake({
    required final String documentId,
    required final String dateOfIntake,
    required final List<IntakeItem> breakfast,
    required final List<IntakeItem> lunch,
    required final List<IntakeItem> dinner,
    required final int recommendedCalorieIntake,
    required final int currentCalorieIntake,
    required final String latestIntakeExplanation,
  }) async {
    try {
      await userIntake.doc(documentId).update({
        userIntakeDateOfIntakeFieldName: dateOfIntake,
        userIntakeBreakfastFieldName:
            breakfast.map((item) => item.toMap()).toList(),
        userIntakeLunchFieldName: lunch.map((item) => item.toMap()).toList(),
        userIntakeDinnerFieldName: dinner.map((item) => item.toMap()).toList(),
        userIntakeRecommendedCalorieIntakeFieldName: recommendedCalorieIntake,
        userIntakeCurrentCalorieIntakeFieldName: currentCalorieIntake,
        userIntakeLatestIntakeExplanationFieldName: latestIntakeExplanation,
      });
    } catch (e) {
      throw CouldNotUpdateUserIntakeException();
    }
  }

  Future<CloudUserIntake> getUserIntake({
    required String ownerUserId,
    required String dateOfIntake,
  }) async {
    try {
      final querySnapshot = await userIntake
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .where(userIntakeDateOfIntakeFieldName, isEqualTo: dateOfIntake)
          .get();
      // Check if we have any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Extract the first document and convert it to CloudLatestFoodRecipeQuery
        final userDoc = querySnapshot.docs.first;
        return CloudUserIntake.fromSnapshot(userDoc);
      } else {
        throw CouldNotGetUserIntakeException();
      }
    } catch (e) {
      throw CouldNotGetUserIntakeException();
    }
  }

  Future<String> createNewUserIntake({
    required String ownerUserId,
    required String dateOfIntake,
    required List<IntakeItem> breakfast,
    required List<IntakeItem> lunch,
    required List<IntakeItem> dinner,
    required int recommendedCalorieIntake,
    required int currentCalorieIntake,
    required String latestIntakeExplanation,
  }) async {
    try {
      final docRef = await userIntake.add({
        ownerUserIdFieldName: ownerUserId,
        userIntakeDateOfIntakeFieldName: dateOfIntake,
        userIntakeBreakfastFieldName: breakfast,
        userIntakeLunchFieldName: lunch,
        userIntakeDinnerFieldName: dinner,
        userIntakeRecommendedCalorieIntakeFieldName: recommendedCalorieIntake,
        userIntakeCurrentCalorieIntakeFieldName: currentCalorieIntake,
        userIntakeLatestIntakeExplanationFieldName: latestIntakeExplanation,
      });
      return docRef.id; // Return the document ID
    } catch (e) {
      throw CouldNotCreateUserIntakeException();
    }
  }

  Stream<CloudUserIntake> getUserIntakeStream({
    required String ownerUserId,
    required String dateOfIntake,
  }) {
    return userIntake
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .where(userIntakeDateOfIntakeFieldName, isEqualTo: dateOfIntake)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final userDoc = snapshot.docs.first;
        return CloudUserIntake.fromSnapshot(userDoc);
      } else {
        throw CouldNotGetUserIntakeException();
      }
    });
  }

  // For userDailyWaterIntake
  Future<void> deleteUserDailyWaterIntake({required String documentId}) async {
    try {
      await userDailyWaterIntake.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteUserDailyWaterIntakeException();
    }
  }

  Future<void> updateUserDailyWaterIntake({
    required final String documentId,
    required final String dateOfIntake,
    required final double recommendedMinWaterIntake,
    required final double recommendedMaxWaterIntake,
    required final double currentWaterIntake,
    required final double yesterdayWaterIntake,
  }) async {
    try {
      await userDailyWaterIntake.doc(documentId).update({
        userDailyWaterIntakeDateOfIntakeFieldName: dateOfIntake,
        userDailyWaterIntakeRecommendedMinWaterIntakeFieldName:
            recommendedMinWaterIntake,
        userDailyWaterIntakeRecommendedMaxWaterIntakeFieldName:
            recommendedMaxWaterIntake,
        userDailyWaterIntakeCurrentWaterIntakeFieldName: currentWaterIntake,
        userDailyWaterIntakeYesterdayWaterIntakeFieldName: yesterdayWaterIntake,
      });
    } catch (e) {
      throw CouldNotUpdateUserDailyWaterIntakeException();
    }
  }

  Future<CloudUserDailyWaterIntake> getUserDailyWaterIntake({
    required String ownerUserId,
  }) async {
    try {
      final querySnapshot = await userDailyWaterIntake
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get();
      // Check if we have any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Extract the first document and convert it
        final userDoc = querySnapshot.docs.first;
        return CloudUserDailyWaterIntake.fromSnapshot(userDoc);
      } else {
        throw CouldNotGetUserDailyWaterIntakeException();
      }
    } catch (e) {
      throw CouldNotGetUserDailyWaterIntakeException();
    }
  }

  Future<String> createNewUserDailyWaterIntake({
    required String ownerUserId,
    required String dateOfIntake,
    required double recommendedMinWaterIntake,
    required double recommendedMaxWaterIntake,
    required double currentWaterIntake,
    required double yesterdayWaterIntake,
  }) async {
    try {
      final docRef = await userDailyWaterIntake.add({
        ownerUserIdFieldName: ownerUserId,
        userDailyWaterIntakeDateOfIntakeFieldName: dateOfIntake,
        userDailyWaterIntakeRecommendedMinWaterIntakeFieldName:
            recommendedMinWaterIntake,
        userDailyWaterIntakeRecommendedMaxWaterIntakeFieldName:
            recommendedMaxWaterIntake,
        userDailyWaterIntakeCurrentWaterIntakeFieldName: currentWaterIntake,
        userDailyWaterIntakeYesterdayWaterIntakeFieldName: yesterdayWaterIntake,
      });
      return docRef.id; // Return the document ID
    } catch (e) {
      throw CouldNotCreateUserDailyWaterIntakeException();
    }
  }

  // ensures that only one instance of the
  // FirebaseCloudStorage class exists throughout the application.

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
