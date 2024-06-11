<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Admin;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use App\Models\Post;
use App\Models\Comment;

class AdminController extends Controller
{
    // Admin login method
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // Retrieve the admin by email
        $admin = Admin::where('email', $request->email)->first();

        // Check if admin exists and the password matches the hashed password
        if (!$admin || !Hash::check($request->password, $admin->password)) {
            throw ValidationException::withMessages([
                'email' => ['Invalid credentials.'],
            ]);
        }

        // Generate token for admin
        $token = $admin->createToken('admin')->plainTextToken;

        // Respond with success message and token
        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
        ]);
    }

    // Method to retrieve all users
    public function getAllUsers(Request $request)
    {
        $users = User::select('id', 'email', 'fullname', 'username', 'profile_picture', 'bio','birthday')->get();
    
        return response()->json([
            'users' => $users,
        ]);
    }

    public function deleteUser($id)
{
    // Find the user by ID
    $user = User::find($id);

    // Check if the user exists
    if (!$user) {
        return response()->json([
            'message' => 'User not found'
        ], 404);
    }

    // Delete the user
    $user->delete();

    return response()->json([
        'message' => 'User deleted successfully'
    ]);
}


    // Method to retrieve daily user registrations
    public function getDailyUserRegistrations(Request $request)
    {
        // Assuming you have a `created_at` column in the users table for registration date
        $dailyRegistrations = User::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->groupBy('date')
            ->orderBy('date', 'asc')
            ->get();
    
        return response()->json([
            'dailyRegistrations' => $dailyRegistrations,
        ]);
    }

    public function getAdminProfile(Request $request)
    {
        // Retrieve the currently authenticated admin
        $admin = Auth::user(); // Assuming the `auth:sanctum` guard has authenticated the admin
    
        if (!$admin) {
            return response()->json(['error' => 'Admin not found'], 404);
        }
    
        // Define the base URL for admin profile pictures
        $baseUrl = url('/admin_picture/');
    
        // Return the admin's profile information as JSON
        return response()->json([
            'name' => $admin->name,
            'email' => $admin->email,
            'profile_picture' => $baseUrl . $admin->profile_picture, // Include the full URL to the profile picture
        ]);
    }
    
    public function getPostCount(Request $request)
    {
        // Assuming you want to count all posts regardless of the user
        $postCount = Post::count();
    
        return response()->json([
            'postCount' => $postCount,
        ]);
    }
    public function getDailyPostCounts(Request $request)
{
    // Assuming you have a 'created_at' column in your posts table for the post creation date
    $dailyPostCounts = Post::selectRaw('DATE(created_at) as date, COUNT(*) as count')
        ->groupBy('date')
        ->orderBy('date', 'asc')
        ->get();
    
    return response()->json([
        'dailyPostCounts' => $dailyPostCounts,
    ]);
}
// Get all posts
public function getAllPosts(Request $request)
{
    $posts = Post::with('user:id,username,profile_picture')
        ->select('id', 'title', 'content', 'photo', 'user_id')
        ->orderBy('created_at', 'desc')
        ->get();

    return response()->json([
        'posts' => $posts,
    ]);
}

// Delete a post
public function deletePost($id)
{
    $post = Post::find($id);

    if (!$post) {
        return response()->json([
            'message' => 'Post not found',
        ], 404);
    }

    // Delete the photo file from storage, if it exists
    if ($post->photo && file_exists(public_path('posts/' . $post->photo))) {
        unlink(public_path('posts/' . $post->photo));
    }

    // Delete the post along with its comments and likes
    $post->comments()->delete();
    $post->likes()->delete();
    $post->delete();

    return response()->json([
        'message' => 'Post deleted successfully',
    ]);
}


// Get all comments
public function getAllComments(Request $request)
{
    // Fetch all comments from the database
    $comments = Comment::with('user:id,username,profile_picture')->get();

    // Return comments as JSON
    return response()->json([
        'comments' => $comments,
    ]);
}

// Delete a comment
public function deleteComment($id)
{
    // Find the comment by ID
    $comment = Comment::find($id);

    if (!$comment) {
        return response()->json([
            'message' => 'Comment not found',
        ], 404);
    }

    // Delete the comment
    $comment->delete();

    return response()->json([
        'message' => 'Comment deleted successfully',
    ]);
}
}
