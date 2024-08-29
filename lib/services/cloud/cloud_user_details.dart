import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudUserDetails {
  final String documentId;
  final String ownerUserId;
  final DateTime userDateOfBirth;
  final int userWeight;
  final int userHeight;
  final List<String> userDiseases;
  final String userGender;
  final String userGoal;
  const CloudUserDetails({
    required this.documentId,
    required this.ownerUserId,
    required this.userDateOfBirth,
    required this.userWeight,
    required this.userHeight,
    required this.userDiseases,
    required this.userGender,
    required this.userGoal,
  });

  CloudUserDetails.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        userDateOfBirth = (snapshot.data()[dobFieldName] as Timestamp).toDate(),
        userWeight = snapshot.data()[weightFieldName] as int,
        userHeight = snapshot.data()[heightFieldName] as int,
        userDiseases =
            List<String>.from(snapshot.data()[diseasesFieldName] ?? []),
        userGender = snapshot.data()[genderFieldName] as String,
        userGoal = snapshot.data()[goalFieldName] as String;
}
