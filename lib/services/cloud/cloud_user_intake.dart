import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/intake_item.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudUserIntake {
  final String documentId;
  final String ownerUserId;
  final String dateOfIntake;
  final List<IntakeItem> breakfast;
  final List<IntakeItem> lunch;
  final List<IntakeItem> dinner;
  final int recommendedCalorieIntake;
  final int currentCalorieIntake;
  final String latestIntakeExplanation;

  const CloudUserIntake({
    required this.documentId,
    required this.ownerUserId,
    required this.dateOfIntake,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.recommendedCalorieIntake,
    required this.currentCalorieIntake,
    required this.latestIntakeExplanation,
  });

  CloudUserIntake.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String? ??
            '', // Default to empty string if null
        dateOfIntake =
            snapshot.data()[userIntakeDateOfIntakeFieldName] as String? ??
                '', // Default to empty string if null
        breakfast =
            (snapshot.data()[userIntakeBreakfastFieldName] as List<dynamic>? ??
                    []) // Handle null breakfast list
                .map((item) => IntakeItem.fromMap(item as Map<String, dynamic>))
                .toList(),
        lunch = (snapshot.data()[userIntakeLunchFieldName] as List<dynamic>? ??
                []) // Handle null lunch list
            .map((item) => IntakeItem.fromMap(item as Map<String, dynamic>))
            .toList(),
        dinner =
            (snapshot.data()[userIntakeDinnerFieldName] as List<dynamic>? ??
                    []) // Handle null dinner list
                .map((item) => IntakeItem.fromMap(item as Map<String, dynamic>))
                .toList(),
        recommendedCalorieIntake = (snapshot
                .data()[userIntakeRecommendedCalorieIntakeFieldName] as int?) ??
            0, // Default to 0if null
        currentCalorieIntake = (snapshot
                .data()[userIntakeCurrentCalorieIntakeFieldName] as int?) ??
            0, // Default to 0
        latestIntakeExplanation =
            snapshot.data()[userIntakeLatestIntakeExplanationFieldName]
                    as String? ??
                ''; // Default to empty string if null
}
