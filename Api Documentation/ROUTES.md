# Journal Management System API Routes

This document provides a comprehensive list of all API routes available in the Journal Management System.

## Authentication Routes

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| POST | `/api/login` | ApiAuthController@login | Authenticate user and return token | No |
| POST | `/api/register` | ApiAuthController@register | Register new user | No |
| POST | `/api/logout` | ApiAuthController@logout | Logout and invalidate token | Yes |
| POST | `/api/forgot-password` | ApiAuthController@forgotPassword | Request password reset link | No |
| POST | `/api/reset-password` | ApiAuthController@resetPassword | Reset password using token | No |

## Public Routes

### Journals

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/public/journals` | ApiJournalController@index | List all journals | No |
| GET | `/api/public/journals/{journal}` | ApiJournalController@show | Get journal details | No |

### Articles

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/public/articles` | ApiArticleController@index | List all articles | No |
| GET | `/api/public/articles/{article}` | ApiArticleController@show | Get article details | No |
| GET | `/api/public/articles/featured` | ApiArticleController@featured | Get featured articles | No |
| GET | `/api/public/articles/recent` | ApiArticleController@recent | Get recent articles | No |

### Issues

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/public/issues` | ApiIssueController@index | List all issues | No |
| GET | `/api/public/issues/{issue}` | ApiIssueController@show | Get issue details | No |
| GET | `/api/public/issues/recent` | ApiIssueController@recent | Get recent issues | No |

### Editorial Board

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/public/editorial-board` | ApiEditorialBoardController@index | List editorial board members | No |

### Keywords

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/public/keywords/popular` | ApiKeywordController@popular | Get popular keywords | No |

### Search

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/public/search` | ApiArticleController@search | Search across articles, authors, journals | No |

### File Downloads

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/download/article/{article}/{file_type}` | ApiArticleController@download | Download article files | No |

## Protected Routes

### User Profile

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/user` | Laravel built-in | Get current user information | Yes |
| PUT | `/api/v1/user/profile` | ApiAuthController@updateProfile | Update user profile | Yes |
| POST | `/api/v1/user/change-password` | ApiAuthController@changePassword | Change user password | Yes |

### Articles

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/articles` | ApiArticleController@index | List articles | Yes |
| POST | `/api/v1/articles` | ApiArticleController@store | Create article | Yes |
| GET | `/api/v1/articles/{article}` | ApiArticleController@show | Get article details | Yes |
| PUT | `/api/v1/articles/{article}` | ApiArticleController@update | Update article | Yes |
| DELETE | `/api/v1/articles/{article}` | ApiArticleController@destroy | Delete article | Yes |

### Authors

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/authors` | ApiAuthorController@index | List authors | Yes |
| POST | `/api/v1/authors` | ApiAuthorController@store | Create author | Yes |
| GET | `/api/v1/authors/{author}` | ApiAuthorController@show | Get author details | Yes |
| PUT | `/api/v1/authors/{author}` | ApiAuthorController@update | Update author | Yes |
| DELETE | `/api/v1/authors/{author}` | ApiAuthorController@destroy | Delete author | Yes |
| GET | `/api/v1/authors/{author}/articles` | ApiAuthorController@articles | Get author's articles | Yes |

### Editorial Board

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/editorial-board` | ApiEditorialBoardController@index | List editorial board members | Yes |
| POST | `/api/v1/editorial-board` | ApiEditorialBoardController@store | Create editorial board member | Yes |
| GET | `/api/v1/editorial-board/{editorialBoard}` | ApiEditorialBoardController@show | Get editorial board member details | Yes |
| PUT | `/api/v1/editorial-board/{editorialBoard}` | ApiEditorialBoardController@update | Update editorial board member | Yes |
| DELETE | `/api/v1/editorial-board/{editorialBoard}` | ApiEditorialBoardController@destroy | Delete editorial board member | Yes |

### Issues

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/issues` | ApiIssueController@index | List issues | Yes |
| POST | `/api/v1/issues` | ApiIssueController@store | Create issue | Yes |
| GET | `/api/v1/issues/{issue}` | ApiIssueController@show | Get issue details | Yes |
| PUT | `/api/v1/issues/{issue}` | ApiIssueController@update | Update issue | Yes |
| DELETE | `/api/v1/issues/{issue}` | ApiIssueController@destroy | Delete issue | Yes |
| GET | `/api/v1/issues/{issue}/articles` | ApiIssueController@articles | Get articles in issue | Yes |

### Keywords

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/keywords` | ApiKeywordController@index | List keywords | Yes |
| POST | `/api/v1/keywords` | ApiKeywordController@store | Create keyword | Yes |
| GET | `/api/v1/keywords/{keyword}` | ApiKeywordController@show | Get keyword details | Yes |
| PUT | `/api/v1/keywords/{keyword}` | ApiKeywordController@update | Update keyword | Yes |
| DELETE | `/api/v1/keywords/{keyword}` | ApiKeywordController@destroy | Delete keyword | Yes |

### Citations

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/citations` | ApiCitationController@index | List citations | Yes |
| POST | `/api/v1/citations` | ApiCitationController@store | Create citation | Yes |
| GET | `/api/v1/citations/{citation}` | ApiCitationController@show | Get citation details | Yes |
| PUT | `/api/v1/citations/{citation}` | ApiCitationController@update | Update citation | Yes |
| DELETE | `/api/v1/citations/{citation}` | ApiCitationController@destroy | Delete citation | Yes |
| GET | `/api/v1/citations/citing/{articleId}` | ApiCitationController@citingArticles | Get articles citing a specific article | Yes |
| GET | `/api/v1/citations/cited/{articleId}` | ApiCitationController@citedArticles | Get articles cited by a specific article | Yes |

### Submissions

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/submissions` | ApiSubmissionController@index | List user's submissions | Yes |
| POST | `/api/v1/submissions` | ApiSubmissionController@store | Create submission | Yes |
| GET | `/api/v1/submissions/{submission}` | ApiSubmissionController@show | Get submission details | Yes |
| PUT | `/api/v1/submissions/{submission}` | ApiSubmissionController@update | Update submission | Yes |
| DELETE | `/api/v1/submissions/{submission}` | ApiSubmissionController@destroy | Delete submission | Yes |
| POST | `/api/v1/submissions/{submission}/upload` | ApiSubmissionController@upload | Upload file for submission | Yes |
| GET | `/api/v1/submissions/{submission}/status` | ApiSubmissionController@status | Get submission status | Yes |

### Reviews

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/reviews` | ApiReviewController@index | List assigned reviews | Yes |
| GET | `/api/v1/reviews/{review}` | ApiReviewController@show | Get review details | Yes |
| POST | `/api/v1/reviews/{review}/submit` | ApiReviewController@submit | Submit review | Yes |
| POST | `/api/v1/reviews/{review}/decline` | ApiReviewController@decline | Decline review invitation | Yes |
| GET | `/api/v1/reviews/{review}/download/{fileId}` | ApiReviewController@download | Download submission file | Yes |

### Notifications

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/notifications` | ApiAuthController@notifications | Get user notifications | Yes |
| POST | `/api/v1/notifications/mark-read` | ApiAuthController@markNotificationsAsRead | Mark notifications as read | Yes |
| GET | `/api/v1/notifications/unread-count` | ApiAuthController@unreadNotificationsCount | Get unread notification count | Yes |

### Journals

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| GET | `/api/v1/journals/{journal}/articles` | ApiJournalController@articles | Get articles in journal | Yes |

## Additional Resources

These routes are also defined but may be handled by their respective controllers:

| Method | URL | Controller | Description | Auth Required |
|--------|-----|------------|-------------|--------------|
| API Resource | `/api/v1/affiliations` | AffiliationController | CRUD for affiliations | Yes |
| API Resource | `/api/v1/publishers` | PublisherController | CRUD for publishers | Yes | 