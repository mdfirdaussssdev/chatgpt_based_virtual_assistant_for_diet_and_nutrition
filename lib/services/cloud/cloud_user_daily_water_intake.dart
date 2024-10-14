import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudUserDailyWaterIntake {
  final String documentId;
  final String ownerUserId;
  final String dateOfIntake;
  final double recommendedMinWaterIntake;
  final double recommendedMaxWaterIntake;
  final double currentWaterIntake;
  final double yesterdayWaterIntake;

  const CloudUserDailyWaterIntake({
    required this.documentId,
    required this.ownerUserId,
    required this.dateOfIntake,
    required this.recommendedMinWaterIntake,
    required this.recommendedMaxWaterIntake,
    required this.currentWaterIntake,
    required this.yesterdayWaterIntake,
  });

  CloudUserDailyWaterIntake.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String? ??
            '', // Default to empty string if null
        dateOfIntake =
            snapshot.data()[userIntakeDateOfIntakeFieldName] as String? ??
                '', // Default to empty string if null
        recommendedMinWaterIntake = (snapshot.data()[
                    userDailyWaterIntakeRecommendedMinWaterIntakeFieldName]
                as double?) ??
            0.0, // Default to 0 if null
        recommendedMaxWaterIntake = (snapshot.data()[
                    userDailyWaterIntakeRecommendedMaxWaterIntakeFieldName]
                as double?) ??
            0.0,
        currentWaterIntake =
            (snapshot.data()[userDailyWaterIntakeCurrentWaterIntakeFieldName]
                    as double?) ??
                0.0, // Default to empty string if null
        yesterdayWaterIntake =
            (snapshot.data()[userDailyWaterIntakeYesterdayWaterIntakeFieldName]
                    as double?) ??
                0.0; // Default to empty string if null
}
