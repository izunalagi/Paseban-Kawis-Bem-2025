# Route yang hilang di backend

Error "no query result for model app\models\options" menunjukkan bahwa route untuk delete option belum ada di `routes/api.php`.

**Tambahkan route berikut di `routes/api.php`:**

```php
Route::delete('/quiz/options/{option_id}', [QuizController::class, 'destroyOption']);
```

**Lokasi:** `../API-Paseban-Kawis/routes/api.php`

**Tambahkan setelah route quiz lainnya:**

```php
// Quiz routes
Route::get('/quiz', [QuizController::class, 'listQuiz']);
Route::post('/quiz', [QuizController::class, 'store']);
Route::post('/quiz/{quiz_id}', [QuizController::class, 'update']);
Route::delete('/quiz/{quiz_id}', [QuizController::class, 'destroy']);
Route::post('/quiz/{quiz_id}/questions', [QuizController::class, 'addQuestion']);
Route::get('/quiz/{quiz_id}/questions', [QuizController::class, 'getQuestions']);
Route::post('/quiz/questions/{question_id}', [QuizController::class, 'updateQuestion']);
Route::delete('/quiz/questions/{question_id}', [QuizController::class, 'destroyQuestion']);
Route::post('/quiz/questions/{question_id}/options', [QuizController::class, 'addOption']);
Route::post('/quiz/options/{option_id}', [QuizController::class, 'updateOption']);
Route::delete('/quiz/options/{option_id}', [QuizController::class, 'destroyOption']); // TAMBAHKAN INI
```

**Setelah menambahkan route, restart server Laravel:**

```bash
php artisan serve
```

**Kemudian test lagi di Flutter untuk delete pilihan.**
