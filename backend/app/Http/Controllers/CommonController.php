<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Otp;
use Illuminate\Support\Facades\Storage;
use App\Models\Post;
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;
use App\Models\User;
use App\Models\Comment;
use App\Models\Like;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
class CommonController extends Controller
{
    //
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|between:2,100',
            'email' => 'required|string|max:100|email|unique:users',
            'password' => 'required|string|confirmed|min:6'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => $validator->errors()->first()
            ], 401);
        }

        // Generate and store OTP
        $otp = rand(1000, 9999);

        // Store user details along with OTP and get the user ID
        $user = User::create(array_merge($validator->validated(), ['password' => Hash::make($request->password), 'otp' => $otp]));

        $this->mail($validator->validated()['email'], $otp);

        $token = $user->createToken('YourDeviceName')->plainTextToken;

        return response()->json([
            'message' => 'User registered successfully',
            'token' => $token,
        ]);
    }
    
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'required',
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $request->user()->createToken($request->device_name)->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
        ]);
    }




    public function verifyOtp(Request $request)
{
    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
        'otp' => 'required|digits:4',
    ]);
    
    if ($validator->fails()) {
        return response()->json([
            'message' => $validator->errors()->first()
        ], 401);
    }
    
    $user = User::where('email', $request->email)->first();
    
    if (!$user) {
        return response()->json([
            'message' => 'User not found'
        ], 404);
    }
    
    // Check if OTP matches
    if ($user->otp !== (int)$request->otp) {
        return response()->json([
            'message' => 'Invalid OTP'
        ], 401);
    }
    
    // Clear OTP after successful verification
    $user->otp = -1;
    $user->save();
    
    // Return success message
    return response()->json([
        'message' => 'OTP verified successfully',
        'user_id' => $user->id // Optionally, you can return the user ID
    ]);
}


public function newpassword(Request $request)
{
    // Validate the request input
    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
        'newpassword' => 'required|string|min:6',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'message' => $validator->errors()->first(),
        ], 401);
    }

    // Find the user by email
    $user = User::where('email', $request->email)->first();

    if (!$user) {
        return response()->json([
            'message' => 'User not found',
        ], 404);
    }

    // Update the user's password
    $user->newpassword = Hash::make($request->newpassword); // Use Hash to encrypt the password
    $user->save(); // Save the user to the database

    return response()->json([
        'message' => 'Password updated successfully.',
    ]);
}







public function addProfile(Request $request)
{
    $validator = Validator::make($request->all(), [
        'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // Validate file as an image
        'username' => 'nullable|string|max:100|unique:users',
        'fullname' => 'nullable|string|max:255',
        'birthday' => 'nullable|date',
        'bio' => 'nullable|string|max:1000',
        'email' => 'required|email',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'message' => $validator->errors()->first()
        ], 401);
    }
    $imageName = time() . '.' . $validator->validated()['profile_picture']->extension(); 
    Storage::disk('public')->putFileAs('profile_pictures',$validator->validated()['profile_picture'],$imageName);
    $user = User::where('email', $request->email)->first();

    if (!$user) {
        return response()->json([
            'message' => 'User not found'
        ], 404);
    }

    
   
    // Update other profile details
    $user->update(array_merge($validator->validated(),['profile_picture'=>$imageName]));

    return response()->json([
        'message' => 'Profile details added successfully'
    ]);
}

public function updateProfile(Request $request)
{
    try {
        $validator = Validator::make($request->all(), [
            'fullname' => 'nullable|string|max:255',
            'birthday' => 'nullable|date',
            'bio' => 'nullable|string|max:1000',
            'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => $validator->errors()->first()
            ], 400); // Bad Request
        }

        $user = $request->user(); // Retrieve authenticated user

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404); // Not Found
        }

        // Update other fields
        if ($request->filled('fullname')) {
            $user->fullname = $request->fullname;
        }

        if ($request->filled('birthday')) {
            $user->birthday = $request->birthday;
        }

        if ($request->filled('bio')) {
            $user->bio = $request->bio;
        }

        if ($request->hasFile('profile_picture')) {
            $imageName = time() . '.' . $request->file('profile_picture')->extension();
            $request->file('profile_picture')->storeAs('profile_pictures', $imageName, 'public');
            $user->profile_picture = $imageName;
        }

        $user->save();

        return response()->json([
            'message' => 'Profile details updated successfully'
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'error' => 'Failed to update profile: ' . $e->getMessage()
        ], 400);
    }
}


public function getProfile(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'profile_picture' => $user->profile_picture,
            'username' => $user->username,
            'fullname' => $user->fullname,
            'birthday' => $user->birthday,
            'bio' => $user->bio,
            
        ]);
    }

    public function newPost(Request $request)
    {
      $imageName=null;
      $validator = validator::make($request->all(),[
        'title'=>'required|string|between:2,100',
        'content'=>'required|string|max:10000|',
        'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
      ]);
      if($validator->fails())
      {
        return response()->json([
            'message'=>$validator->errors()->first()
        ],401);
      }
      if(isset($validator->validated()['photo']))
      {
        $imageName = time() . '.' . $validator->validated()['photo']->extension(); 
        Storage::disk('public')->putFileAs('posts',$validator->validated()['photo'],$imageName);
      }
      Post::create(array_merge($validator->validated(),['photo'=>$imageName ,'user_id'=>auth()->user()->id]));
     
    }


    public function allPosts(Request $request)
{
    $user = $request->user();
    if (!$user) {
        return response()->json([
            'message' => 'User not found'
        ], 404);
    }
    $posts = Post::where('user_id', $user->id)->paginate(5);
    
    return response()->json([
        'posts' => $posts,
    ]);
}



public function followedUsersPosts(Request $request)
{
    $user = $request->user();

    if (!$user) {
        return response()->json([
            'message' => 'User not found'
        ], 404);
    }

    $followedUsersPosts = Post::whereIn('user_id', $user->followings()->pluck('users.id')->toArray())
        ->with('user:id,username,profile_picture')
        ->paginate(5);

    return response()->json([
        'posts' => $followedUsersPosts,
    ]);
}


public function getAllUsers(Request $request)
{
    $users = User::select('id', 'username', 'profile_picture', 'bio')->get();

    return response()->json([
        'users' => $users,
    ]);
}

public function followUser(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => $validator->errors()->first()
            ], 401);
        }

        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        $user->followings()->attach($request->user_id);

        return response()->json([
            'message' => 'User followed successfully'
        ]);
    }


    public function editPost(int $id,Request $request)
    { $post=  Post::find($id);
      $imageName=null;
      $validator = validator::make($request->all(),[
        'title'=>'required|string|between:2,100',
        'content'=>'required|string|max:10000|',
        'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
      ]);
      if($validator->fails())
      {
        return response()->json([
            'message'=>$validator->errors()->first()
        ],401);
      }
      if(isset($validator->validated()['photo']))
      {
        if (file_exists(public_path('posts/'.$post->photo)))
        {
           unlink(public_path('posts/'.$post->photo));
        }

        $imageName = time() . '.' . $validator->validated()['photo']->extension(); 
        Storage::disk('public')->putFileAs('posts',$validator->validated()['photo'],$imageName);
      }

      $post->update(array_merge($validator->validated(),['photo'=>$imageName]));
    }


    public function deletePost(int $id)
{
    $post = Post::find($id);
    
    if (isset($post->photo)) {
        if (file_exists(public_path('posts/' . $post->photo))) {
            unlink(public_path('posts/' . $post->photo));
        }
    }
    
    $post->comments()->delete();  
    $post->likes()->delete();
    $post->delete();
}


public function comment(Request $request, int $postId)
{
    // Validate request data
    $validator = Validator::make($request->all(), [
        'comment' => 'required|string|max:10000',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'message' => $validator->errors()->first()
        ], 401);
    }

    // Retrieve the post and check its existence
    $post = Post::find($postId);
    if (!$post) {
        return response()->json([
            'message' => 'Post not found'
        ], 404);
    }

    // Create the comment
    $comment = new Comment();
    $comment->comment = $request->comment;
    $comment->user_id = $request->user()->id; // Authenticated user's ID
    $comment->post_id = $postId;
    $comment->save();

    return response()->json([
        'message' => 'Comment added successfully',
        'comment' => $comment,
    ], 201);
}


public function getComments($postId)
{
    // Fetch all comments for the specified post ID
    $comments = Comment::where('post_id', $postId)
        ->with('user:id,username,profile_picture') // Optionally, fetch the username and profile picture of the user who made the comment
        ->get();

    // Return comments as a JSON response
    return response()->json($comments);
}



public function like(Request $request, int $postId)
{
    // Retrieve the post and check its existence
    $post = Post::find($postId);
    if (!$post) {
        return response()->json([
            'message' => 'Post not found'
        ], 404);
    }

    // Check if the user has already liked the post
    $existingLike = $post->likes()->where('user_id', $request->user()->id)->first();
    if ($existingLike) {
        return response()->json([
            'message' => 'You have already liked this post'
        ], 400);
    }

    // Create the like
    $like = new Like();
    $like->user_id = $request->user()->id;
    $like->post_id = $postId;
    $like->save();

    return response()->json([
        'message' => 'Post liked successfully',
        'like' => $like,
    ], 201);
}


public function getPostLikeCount(int $postId)
{
    // Retrieve the post by ID
    $post = Post::find($postId);
    
    if (!$post) {
        return response()->json([
            'message' => 'Post not found'
        ], 404);
    }

    // Return the like count
    return response()->json([
        'like_count' => $post->like_count,
    ]);
}


     public function mail($address, $otp)
    {
        $mail = new PHPMailer(true);

        try {
            $mail->isSMTP();
            $mail->Host       = 'smtp.gmail.com';
            $mail->SMTPAuth   = true;
            $mail->Username   = 'ushanichathushka23@gmail.com'; // Update with your email
            $mail->Password   = 'eoxfwljbruxulfmj'; // Update with your email password
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
            $mail->Port       = 465;

            $mail->setFrom('ushanichathushka23@gmail.com', 'DORA OTP');
            $mail->addAddress($address);
            $mail->isHTML(true);
            $mail->Subject = 'OTP Verification';
            $mail->Body = 'Your OTP for DORA signup: ' . $otp;

            $mail->send();
        } catch (Exception $e) {
            // Log error or handle it as needed
        }
    }
}