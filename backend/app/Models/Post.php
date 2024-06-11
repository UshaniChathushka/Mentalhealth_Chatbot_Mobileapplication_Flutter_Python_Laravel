<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function comments()
{
    return $this->hasMany(Comment::class);
}


    public function likes()
    {
        return $this->hasMany(Like::class);
    }

    // Method to get the comment count for a post
    public function getCommentCountAttribute()
    {
        return $this->comments()->count();
    }

    // Method to get the like count for a post
    public function getLikeCountAttribute()
    {
        return $this->likes()->count();
    }


    public function user()
{
    return $this->belongsTo(User::class);
}
    
}
