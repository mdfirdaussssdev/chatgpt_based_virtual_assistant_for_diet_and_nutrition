import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_constants.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCloudStorage {
  // name of collection is userDetails in Firebase Database
  final userdetails = FirebaseFirestore.instance.collection('userDetails');

  Future<void> deleteUserDetails({required String documentId}) async {
    try {
      await userdetails.doc(documentId).delete();
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
    required String userGoal,
  }) async {
    try {
      await userdetails.doc(documentId).update({
        dobFieldName: Timestamp.fromDate(userDateOfBirth),
        weightFieldName: userWeight,
        heightFieldName: userHeight,
        diseasesFieldName: userDiseases,
        goalFieldName: userGoal,
      });
    } catch (e) {
      throw CouldNotUpdateUserDetailsException();
    }
  }

  Future<CloudUserDetails> getUserDetails({required String ownerUserId}) async {
    try {
      final querySnapshot = await userdetails
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get();
      // Check if we have any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Extract the first document and convert it to CloudNote
        return CloudUserDetails.fromSnapshot(querySnapshot.docs.first);
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
    required String userGoal,
  }) async {
    await userdetails.add({
      ownerUserIdFieldName: ownerUserId,
      dobFieldName: userDateOfBirth,
      weightFieldName: userWeight,
      heightFieldName: heightFieldName,
      diseasesFieldName: userDiseases,
      goalFieldName: userGoal,
    });
  }

  // ensures that only one instance of the
  // FirebaseCloudStorage class exists throughout the application.

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
