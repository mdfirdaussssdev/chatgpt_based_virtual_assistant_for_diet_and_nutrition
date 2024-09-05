class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

// Create Part CRUD
class CouldNotCreateUserDetailsException extends CloudStorageExceptions {}

// Read Part CRUD
class CouldNotGetUserDetailsException extends CloudStorageExceptions {}

// Update Part CRUD
class CouldNotUpdateUserDetailsException extends CloudStorageExceptions {}

// Delete Part CRUD
class CouldNotDeleteUserDetailsException extends CloudStorageExceptions {}

class FoodNutritionQueryAlreadyExistsException extends CloudStorageExceptions {}

class CouldNotGetFoodNutritionQueryException extends CloudStorageExceptions {}

class CouldNotUpdateFoodNutritionQueryException
    extends CloudStorageExceptions {}

class CouldNotDeleteFoodNutritionQueryException
    extends CloudStorageExceptions {}
