# Mobile App Backend README

This README provides instructions on setting up and running the backend for your mobile app. The backend is built using Laravel, a PHP web framework. Follow the steps below to get started.

## Prerequisites
- PHP (>=7.3)
- Composer
- MySQL
- Laravel (installed globally)

## Installation Steps
1. Clone or download the backend code to your local machine.
2. Navigate to the project directory using the terminal/command prompt.
3. Install PHP dependencies by running the following command:
   ```
   composer install
   ```
4. Create a MySQL database for the project.
5. Rename the `.env.example` file to `.env`.
6. Update the `.env` file with your database credentials:

    ```
    DB_CONNECTION=mysql
    DB_HOST=127.0.0.1
    DB_PORT=3306
    DB_DATABASE=your_database_name
    DB_USERNAME=your_database_username
    DB_PASSWORD=your_database_password
    ```

7. Generate an application key by running the following command:
   ```
   php artisan key:generate
   ```
8. Migrate the database by running the migration command:
   ```
   php artisan migrate
   ```
9. Optionally, you can seed the database with sample data using:
   ```
   php artisan db:seed
   ```

## Running the Server
To start the server, run the following command in the terminal:
```
php artisan serve --host=0.0.0.0 --port=8000
```
This will start the Laravel development server on `http://localhost:8000`.

## API Endpoints
The backend provides various API endpoints for user authentication, CRUD operations on posts, comments, likes, and user management. Below are some of the important endpoints:

- **User Authentication:**
  - `POST /register`: Register a new user.
  - `POST /login`: User login.
  - `POST /verifyOtp`: Verify OTP for user registration.
  - `POST /newpassword`: Update user password.
- **User Profile:**
  - `POST /addProfile`: Add user profile details.
  - `GET /getProfile`: Get user profile details.
  - `POST /updateProfile`: Update user profile details.
- **Posts:**
  - `POST /newPost`: Create a new post.
  - `GET /all-posts`: Get all posts.
  - `GET /followedUsersPosts`: Get posts from followed users.
  - `GET /comments/{postId}`: Get comments for a post.
  - `GET /post/{id}/like-count`: Get like count for a post.
- **Comments and Likes:**
  - `POST /comment/{postId}`: Add a comment to a post.
  - `POST /like/{postId}`: Like a post.
- **Admin Dashboard:**
  - `POST /admin/login`: Admin login.
  - `GET /admin/getAllUsers`: Get all users (admin only).
  - `GET /admin/getAllPosts`: Get all posts (admin only).
  - `GET /admin/getAllComments`: Get all comments (admin only).
  - `GET /admin/daily-post-counts`: Get daily post counts (admin only).

Refer to the source code or API documentation for more details on available endpoints and their usage.

## Environment Configuration
Ensure that the `.env` file is properly configured with your application settings, including database connection details, mail configuration, and other environment variables.

## Contributing
Feel free to contribute to the project by submitting bug reports, feature requests, or pull requests.

## License
This project is licensed under the [MIT License](LICENSE).