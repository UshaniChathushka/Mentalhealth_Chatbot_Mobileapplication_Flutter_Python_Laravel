<?php
use Illuminate\Support\Facades\Route;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use App\Http\Controllers\CommonController; 
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\AdminController;


Route::middleware('auth:sanctum')->group(function () {

  Route::post('newPost',[CommonController::class,'newPost']);  
  Route::post('editPost/{id}',[CommonController::class,'editPost']);  
  Route::delete('deletePost/{id}',[CommonController::class,'deletePost']);  
  Route::post('comment/{id}',[CommonController::class,'comment']);  
  Route::post('like/{id}',[CommonController::class,'like']);  
  Route::get('getProfile', [CommonController::class, 'getProfile']);
  Route::get('/all-posts', [CommonController::class, 'allPosts']);
  Route::post('updateProfile', [CommonController::class, 'updateProfile']);
  Route::post('followUser', [CommonController::class, 'followUser']);
  Route::get('followedUsersPosts', [CommonController::class, 'followedUsersPosts']);
  Route::get('/comments/{postId}', [CommonController::class, 'getComments']);
  Route::get('post/{id}/like-count', [CommonController::class, 'getPostLikeCount']);
 


});
Route::get('errorMsg',function(){return "login first";})->name('login');  
Route::post('register',[CommonController::class,'register']);
Route::post('verifyOtp', [CommonController::class, 'verifyOtp']);
Route::post('addProfile', [CommonController::class, 'addProfile']);
Route::post('login', [CommonController::class, 'login']);
Route::middleware('auth:sanctum')->get('allPosts', [CommonController::class, 'allPosts']);
Route::get('getAllUsers', [CommonController::class, 'getAllUsers']);
Route::post('newpassword', [CommonController::class, 'newpassword']);


Route::get('/daily-user-registrations', [AdminController::class, 'getDailyUserRegistrations']);
Route::delete('/admin/users/{id}', [AdminController::class, 'deleteUser']);
Route::get('/admin/postCount', [AdminController::class, 'getPostCount']);
Route::get('/admin/daily-post-counts', [AdminController::class, 'getDailyPostCounts']);
Route::post('/admin/login', [AdminController::class, 'login']);
Route::get('/admin/getAllUsers', [AdminController::class, 'getAllUsers']);
Route::get('/admin/getAllPosts', [AdminController::class, 'getAllPosts']);
Route::delete('/admin/deletePost/{id}', [AdminController::class, 'deletePost']);
// Fetch all comments
Route::get('/admin/getAllComments', [AdminController::class, 'getAllComments']);

// Delete a comment
Route::delete('/admin/deleteComment/{id}', [AdminController::class, 'deleteComment']);



Route::middleware('auth:sanctum')->get('/admin/profile', [AdminController::class, 'getAdminProfile']);

    

