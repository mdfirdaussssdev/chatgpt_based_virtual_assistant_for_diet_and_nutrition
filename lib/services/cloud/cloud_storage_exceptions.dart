class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

// For userDetails
// Create Part CRUD
class CouldNotCreateUserDetailsException extends CloudStorageExceptions {}

// Read Part CRUD
class CouldNotGetUserDetailsException extends CloudStorageExceptions {}

// Update Part CRUD
class CouldNotUpdateUserDetailsException extends CloudStorageExceptions {}

// Delete Part CRUD
class CouldNotDeleteUserDetailsException extends CloudStorageExceptions {}

// For foodNutritionQuery
class FoodNutritionQueryAlreadyExistsException extends CloudStorageExceptions {}

class CouldNotGetFoodNutritionQueryException extends CloudStorageExceptions {}

class CouldNotUpdateFoodNutritionQueryException
    extends CloudStorageExceptions {}

class CouldNotDeleteFoodNutritionQueryException
    extends CloudStorageExceptions {}

// For foodRecipeQuery
class CouldNotGetFoodRecipeQueryException extends CloudStorageExceptions {}

class CouldNotUpdateFoodRecipeQueryException extends CloudStorageExceptions {}

class CouldNotDeleteFoodRecipeQueryException extends CloudStorageExceptions {}

// For user Intake
class CouldNotDeleteUserIntakeException extends CloudStorageExceptions {}

class CouldNotUpdateUserIntakeException extends CloudStorageExceptions {}

class CouldNotGetUserIntakeException extends CloudStorageExceptions {}

class CouldNotCreateUserIntakeException extends CloudStorageExceptions {}

// For user Daily Water Intake
class CouldNotDeleteUserDailyWaterIntakeException
    extends CloudStorageExceptions {}

class CouldNotUpdateUserDailyWaterIntakeException
    extends CloudStorageExceptions {}

class CouldNotGetUserDailyWaterIntakeException extends CloudStorageExceptions {}

class CouldNotCreateUserDailyWaterIntakeException
    extends CloudStorageExceptions {}
