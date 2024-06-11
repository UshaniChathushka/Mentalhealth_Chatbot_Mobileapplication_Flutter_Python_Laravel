<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    use HasFactory;

    protected $guarded = [];

    /**
     * Define a relationship with the User model.
     * A comment belongs to a user.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}