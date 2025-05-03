# Journal Management System API Documentation

## Overview

This documentation details the API endpoints available for the Journal Management System mobile application. The API provides access to journals, articles, authors, and other resources, as well as user authentication and submission management.

## Base URL

```
https://your-journal-domain.com/api
```

Replace `your-journal-domain.com` with your actual domain.

## Authentication

The API uses Laravel Sanctum for authentication. Protected endpoints require a valid Bearer token.

### Registration

```
POST /register
```

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "johndoe@example.com",
  "password": "securepassword123",
  "password_confirmation": "securepassword123"
}
```

**Response (201 Created):**
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "johndoe@example.com"
  },
  "token": "1|abcdefghijklmnopqrstuvwxyz1234567890"
}
```

### Login

```
POST /login
```

**Request Body:**
```json
{
  "email": "johndoe@example.com",
  "password": "securepassword123"
}
```

**Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "johndoe@example.com"
  },
  "token": "1|abcdefghijklmnopqrstuvwxyz1234567890"
}
```

### Logout

```
POST /logout
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Response (200 OK):**
```json
{
  "message": "Successfully logged out"
}
```

### Forgot Password

```
POST /forgot-password
```

**Request Body:**
```json
{
  "email": "johndoe@example.com"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset link sent to your email"
}
```

### Reset Password

```
POST /reset-password
```

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "email": "johndoe@example.com",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Response (200 OK):**
```json
{
  "message": "Password has been reset successfully"
}
```

## Public Endpoints

These endpoints do not require authentication.

### Journals

#### List Journals

```
GET /public/journals
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)

**Response (200 OK):**
```json
{
  "data": [
    {
      "journal_id": 1,
      "title": "Journal of Science",
      "description": "A journal dedicated to scientific discoveries",
      "publisher": {
        "publisher_id": 1,
        "name": "Academic Publishers"
      },
      "cover_image": "https://your-journal-domain.com/storage/covers/journal-1.jpg"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 75
  }
}
```

#### Get Journal Details

```
GET /public/journals/{journal_id}
```

**Response (200 OK):**
```json
{
  "journal_id": 1,
  "title": "Journal of Science",
  "description": "A journal dedicated to scientific discoveries",
  "issn": "1234-5678",
  "publisher": {
    "publisher_id": 1,
    "name": "Academic Publishers"
  },
  "editorial_board": [
    {
      "editorial_board_id": 1,
      "name": "Dr. Jane Smith",
      "role": "Editor-in-Chief"
    }
  ],
  "cover_image": "https://your-journal-domain.com/storage/covers/journal-1.jpg",
  "recent_issues": [
    {
      "issue_id": 1,
      "issue_number": "Volume 10, Issue 2",
      "publication_date": "2023-06-15"
    }
  ]
}
```

### Articles

#### List Articles

```
GET /public/articles
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)
- `journal_id`: Filter by journal ID
- `issue_id`: Filter by issue ID
- `author_id`: Filter by author ID
- `keyword`: Filter by keyword

**Response (200 OK):**
```json
{
  "data": [
    {
      "article_id": 1,
      "title": "Advancements in Quantum Computing",
      "abstract": "This paper discusses recent advancements in quantum computing...",
      "doi": "10.1234/jscience.2023.001",
      "authors": [
        {
          "author_id": 1,
          "name": "Dr. John Smith",
          "affiliation": "University of Science"
        }
      ],
      "journal": {
        "journal_id": 1,
        "title": "Journal of Science"
      },
      "publication_date": "2023-06-15"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 15,
    "total": 150
  }
}
```

#### Get Article Details

```
GET /public/articles/{article_id}
```

**Response (200 OK):**
```json
{
  "article_id": 1,
  "title": "Advancements in Quantum Computing",
  "abstract": "This paper discusses recent advancements in quantum computing...",
  "content": "Full content of the article...",
  "doi": "10.1234/jscience.2023.001",
  "authors": [
    {
      "author_id": 1,
      "name": "Dr. John Smith",
      "email": "john.smith@university.edu",
      "affiliation": {
        "affiliation_id": 1,
        "institution_name": "University of Science",
        "department_name": "Department of Computer Science"
      },
      "orcid": "0000-0001-2345-6789"
    }
  ],
  "journal": {
    "journal_id": 1,
    "title": "Journal of Science"
  },
  "issue": {
    "issue_id": 1,
    "issue_number": "Volume 10, Issue 2",
    "publication_date": "2023-06-15"
  },
  "keywords": [
    {
      "keyword_id": 1,
      "keyword": "quantum computing"
    },
    {
      "keyword_id": 2,
      "keyword": "computer science"
    }
  ],
  "citations": [
    {
      "citation_id": 1,
      "cited_article": {
        "article_id": 2,
        "title": "Introduction to Quantum Mechanics"
      },
      "citation_context": "As mentioned in the groundbreaking work by Johnson et al. (2020)..."
    }
  ],
  "pdf_url": "https://your-journal-domain.com/api/download/article/1/pdf",
  "publication_date": "2023-06-15"
}
```

#### Get Featured Articles

```
GET /public/articles/featured
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "article_id": 1,
      "title": "Advancements in Quantum Computing",
      "abstract": "This paper discusses recent advancements in quantum computing...",
      "journal": {
        "journal_id": 1,
        "title": "Journal of Science"
      },
      "publication_date": "2023-06-15"
    }
  ]
}
```

#### Get Recent Articles

```
GET /public/articles/recent
```

**Query Parameters:**
- `limit`: Number of articles to return (default: 10)

**Response (200 OK):**
```json
{
  "data": [
    {
      "article_id": 1,
      "title": "Advancements in Quantum Computing",
      "abstract": "This paper discusses recent advancements in quantum computing...",
      "journal": {
        "journal_id": 1,
        "title": "Journal of Science"
      },
      "publication_date": "2023-06-15"
    }
  ]
}
```

### Issues

#### List Issues

```
GET /public/issues
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)
- `journal_id`: Filter by journal ID
- `year`: Filter by publication year

**Response (200 OK):**
```json
{
  "data": [
    {
      "issue_id": 1,
      "issue_number": "Volume 10, Issue 2",
      "issue_title": "Special Issue on Quantum Computing",
      "journal": {
        "journal_id": 1,
        "title": "Journal of Science"
      },
      "publication_date": "2023-06-15",
      "cover_image": "https://your-journal-domain.com/storage/covers/issue-1.jpg"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 75
  }
}
```

#### Get Issue Details

```
GET /public/issues/{issue_id}
```

**Response (200 OK):**
```json
{
  "issue_id": 1,
  "issue_number": "Volume 10, Issue 2",
  "issue_title": "Special Issue on Quantum Computing",
  "journal": {
    "journal_id": 1,
    "title": "Journal of Science"
  },
  "publication_date": "2023-06-15",
  "articles": [
    {
      "article_id": 1,
      "title": "Advancements in Quantum Computing",
      "authors": [
        {
          "author_id": 1,
          "name": "Dr. John Smith"
        }
      ]
    }
  ],
  "cover_image": "https://your-journal-domain.com/storage/covers/issue-1.jpg"
}
```

#### Get Recent Issues

```
GET /public/issues/recent
```

**Query Parameters:**
- `limit`: Number of issues to return (default: 5)

**Response (200 OK):**
```json
{
  "data": [
    {
      "issue_id": 1,
      "issue_number": "Volume 10, Issue 2",
      "issue_title": "Special Issue on Quantum Computing",
      "journal": {
        "journal_id": 1,
        "title": "Journal of Science"
      },
      "publication_date": "2023-06-15",
      "cover_image": "https://your-journal-domain.com/storage/covers/issue-1.jpg"
    }
  ]
}
```

### Editorial Board

#### List Editorial Board Members

```
GET /public/editorial-board
```

**Query Parameters:**
- `journal_id`: Filter by journal ID

**Response (200 OK):**
```json
{
  "data": [
    {
      "editorial_board_id": 1,
      "name": "Dr. Jane Smith",
      "role": "Editor-in-Chief",
      "email": "jane.smith@university.edu",
      "affiliation": {
        "affiliation_id": 1,
        "institution_name": "University of Science",
        "department_name": "Department of Physics"
      }
    }
  ]
}
```

### Keywords

#### Get Popular Keywords

```
GET /public/keywords/popular
```

**Query Parameters:**
- `limit`: Number of keywords to return (default: 10)

**Response (200 OK):**
```json
{
  "data": [
    {
      "keyword_id": 1,
      "keyword": "quantum computing",
      "article_count": 45
    },
    {
      "keyword_id": 2,
      "keyword": "artificial intelligence",
      "article_count": 32
    }
  ]
}
```

### Search

```
GET /public/search
```

**Query Parameters:**
- `query`: Search term
- `type`: Type of search (options: "articles", "authors", "journals", "all")
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)

**Response (200 OK):**
```json
{
  "data": {
    "articles": [
      {
        "article_id": 1,
        "title": "Advancements in Quantum Computing",
        "abstract": "This paper discusses recent advancements in quantum computing..."
      }
    ],
    "authors": [
      {
        "author_id": 1,
        "name": "Dr. John Smith",
        "affiliation": "University of Science"
      }
    ],
    "journals": [
      {
        "journal_id": 1,
        "title": "Journal of Science"
      }
    ]
  },
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 15,
    "total": 45
  }
}
```

## Protected Endpoints

These endpoints require authentication using a Bearer token.

### User Profile

#### Get Current User

```
GET /v1/user
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "johndoe@example.com",
  "created_at": "2023-01-01T12:00:00Z",
  "updated_at": "2023-01-01T12:00:00Z"
}
```

#### Update Profile

```
PUT /v1/user/profile
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Request Body:**
```json
{
  "name": "John D. Doe",
  "bio": "Researcher in quantum computing",
  "affiliation_id": 1
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "John D. Doe",
  "email": "johndoe@example.com",
  "bio": "Researcher in quantum computing",
  "affiliation": {
    "affiliation_id": 1,
    "institution_name": "University of Science"
  },
  "updated_at": "2023-06-15T14:30:00Z"
}
```

#### Change Password

```
POST /v1/user/change-password
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Request Body:**
```json
{
  "current_password": "securepassword123",
  "password": "newsecurepassword456",
  "password_confirmation": "newsecurepassword456"
}
```

**Response (200 OK):**
```json
{
  "message": "Password changed successfully"
}
```

### Submissions

#### List Submissions

```
GET /v1/submissions
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)
- `status`: Filter by status (options: "pending", "under_review", "accepted", "rejected", "published")

**Response (200 OK):**
```json
{
  "data": [
    {
      "submission_id": 1,
      "title": "Advancements in Quantum Computing",
      "abstract": "This paper discusses recent advancements in quantum computing...",
      "journal": {
        "journal_id": 1,
        "title": "Journal of Science"
      },
      "status": "under_review",
      "submitted_at": "2023-05-01T10:15:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 2,
    "per_page": 15,
    "total": 20
  }
}
```

#### Create Submission

```
POST /v1/submissions
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Request Body:**
```json
{
  "title": "New Research on Machine Learning",
  "abstract": "This paper presents new findings in the field of machine learning...",
  "journal_id": 1,
  "authors": [
    {
      "author_id": 1,
      "is_corresponding": true
    },
    {
      "author_id": 2,
      "is_corresponding": false
    }
  ],
  "keywords": [1, 2, 3]
}
```

**Response (201 Created):**
```json
{
  "submission_id": 2,
  "title": "New Research on Machine Learning",
  "abstract": "This paper presents new findings in the field of machine learning...",
  "journal": {
    "journal_id": 1,
    "title": "Journal of Science"
  },
  "status": "pending",
  "submitted_at": "2023-06-15T15:45:00Z",
  "message": "Submission created successfully. Please upload your manuscript files."
}
```

#### Get Submission Details

```
GET /v1/submissions/{submission_id}
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Response (200 OK):**
```json
{
  "submission_id": 1,
  "title": "Advancements in Quantum Computing",
  "abstract": "This paper discusses recent advancements in quantum computing...",
  "journal": {
    "journal_id": 1,
    "title": "Journal of Science"
  },
  "status": "under_review",
  "submitted_at": "2023-05-01T10:15:00Z",
  "authors": [
    {
      "author_id": 1,
      "name": "Dr. John Smith",
      "email": "john.smith@university.edu",
      "is_corresponding": true
    }
  ],
  "keywords": [
    {
      "keyword_id": 1,
      "keyword": "quantum computing"
    }
  ],
  "files": [
    {
      "file_id": 1,
      "filename": "manuscript.pdf",
      "file_type": "manuscript",
      "uploaded_at": "2023-05-01T10:20:00Z"
    }
  ],
  "review_status": {
    "current_round": 1,
    "reviews_completed": 1,
    "reviews_pending": 1
  }
}
```

#### Upload Submission File

```
POST /v1/submissions/{submission_id}/upload
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
Content-Type: multipart/form-data
```

**Request Body:**
```
file: [Binary file data]
file_type: "manuscript" (options: "manuscript", "figures", "supplementary", "cover_letter", "response_to_reviewers")
```

**Response (200 OK):**
```json
{
  "file_id": 1,
  "filename": "manuscript.pdf",
  "file_type": "manuscript",
  "uploaded_at": "2023-06-15T16:00:00Z",
  "message": "File uploaded successfully"
}
```

#### Check Submission Status

```
GET /v1/submissions/{submission_id}/status
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Response (200 OK):**
```json
{
  "submission_id": 1,
  "status": "under_review",
  "submitted_at": "2023-05-01T10:15:00Z",
  "review_status": {
    "current_round": 1,
    "reviews_completed": 1,
    "reviews_pending": 1,
    "estimated_completion": "2023-07-01"
  },
  "history": [
    {
      "status": "pending",
      "date": "2023-05-01T10:15:00Z",
      "comment": "Submission received"
    },
    {
      "status": "under_review",
      "date": "2023-05-10T14:30:00Z",
      "comment": "Sent to reviewers"
    }
  ]
}
```

### Reviews (for reviewers)

#### List Reviews

```
GET /v1/reviews
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)
- `status`: Filter by status (options: "pending", "completed", "declined")

**Response (200 OK):**
```json
{
  "data": [
    {
      "review_id": 1,
      "article": {
        "submission_id": 1,
        "title": "Advancements in Quantum Computing"
      },
      "journal": {
        "journal_id": 1,
        "title": "Journal of Science"
      },
      "due_date": "2023-06-30",
      "status": "pending",
      "assigned_at": "2023-05-10T14:30:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 5
  }
}
```

#### Get Review Details

```
GET /v1/reviews/{review_id}
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Response (200 OK):**
```json
{
  "review_id": 1,
  "article": {
    "submission_id": 1,
    "title": "Advancements in Quantum Computing",
    "abstract": "This paper discusses recent advancements in quantum computing..."
  },
  "journal": {
    "journal_id": 1,
    "title": "Journal of Science"
  },
  "due_date": "2023-06-30",
  "status": "pending",
  "assigned_at": "2023-05-10T14:30:00Z",
  "files": [
    {
      "file_id": 1,
      "filename": "manuscript.pdf",
      "file_type": "manuscript",
      "download_url": "https://your-journal-domain.com/api/v1/reviews/1/download/1"
    }
  ],
  "review_form": {
    "sections": [
      {
        "title": "Originality",
        "type": "rating",
        "options": [1, 2, 3, 4, 5]
      },
      {
        "title": "Comments to Authors",
        "type": "text"
      }
    ]
  }
}
```

#### Submit Review

```
POST /v1/reviews/{review_id}/submit
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Request Body:**
```json
{
  "recommendation": "minor_revision", // options: "accept", "minor_revision", "major_revision", "reject"
  "responses": [
    {
      "section_id": 1,
      "response": 4
    },
    {
      "section_id": 2,
      "response": "The paper presents interesting findings but needs some clarification on methodology."
    }
  ],
  "confidential_comments": "This paper shows promise and should be considered for publication after revisions."
}
```

**Response (200 OK):**
```json
{
  "review_id": 1,
  "status": "completed",
  "submitted_at": "2023-06-15T17:30:00Z",
  "message": "Review submitted successfully"
}
```

#### Decline Review

```
POST /v1/reviews/{review_id}/decline
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Request Body:**
```json
{
  "reason": "I have a conflict of interest with the authors."
}
```

**Response (200 OK):**
```json
{
  "message": "Review invitation declined successfully"
}
```

#### Download Submission File

```
GET /v1/reviews/{review_id}/download/{file_id}
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Response (200 OK):**
Binary file data with appropriate content-type header.

### Citations

#### List Citations

```
GET /v1/citations
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)
- `article_id`: Filter by article ID

**Response (200 OK):**
```json
{
  "data": [
    {
      "citation_id": 1,
      "article": {
        "article_id": 1,
        "title": "Advancements in Quantum Computing"
      },
      "cited_article": {
        "article_id": 2,
        "title": "Introduction to Quantum Mechanics"
      },
      "citation_context": "As mentioned in the groundbreaking work by Johnson et al. (2020)..."
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 2,
    "per_page": 15,
    "total": 25
  }
}
```

#### Get Articles Citing a Specific Article

```
GET /v1/citations/citing/{article_id}
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)

**Response (200 OK):**
```json
{
  "data": [
    {
      "citation_id": 1,
      "article": {
        "article_id": 3,
        "title": "Quantum Computing Applications",
        "authors": ["Dr. Emily Brown", "Dr. Michael Chen"]
      },
      "citation_context": "Building on the fundamental theories presented by Smith (2020)..."
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 5
  }
}
```

#### Get Articles Cited by a Specific Article

```
GET /v1/citations/cited/{article_id}
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)

**Response (200 OK):**
```json
{
  "data": [
    {
      "citation_id": 1,
      "cited_article": {
        "article_id": 2,
        "title": "Introduction to Quantum Mechanics",
        "authors": ["Dr. Robert Johnson", "Dr. Lisa Davis"]
      },
      "citation_context": "As mentioned in the groundbreaking work by Johnson et al. (2020)..."
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 8
  }
}
```

### Specialized Endpoints

#### Get Journal Articles

```
GET /v1/journals/{journal_id}/articles
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)
- `year`: Filter by publication year
- `issue_id`: Filter by issue ID

**Response (200 OK):**
[Similar to the Articles listing response]

#### Get Issue Articles

```
GET /v1/issues/{issue_id}/articles
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)

**Response (200 OK):**
[Similar to the Articles listing response]

#### Get Author Articles

```
GET /v1/authors/{author_id}/articles
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)

**Response (200 OK):**
[Similar to the Articles listing response]

### Notifications

#### Get Notifications

```
GET /v1/notifications
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15)
- `read`: Filter by read status (options: "read", "unread", "all")

**Response (200 OK):**
```json
{
  "data": [
    {
      "notification_id": 1,
      "type": "submission_status",
      "title": "Submission Status Update",
      "message": "Your submission 'Advancements in Quantum Computing' has moved to 'under review' status.",
      "read": false,
      "created_at": "2023-05-10T14:30:00Z",
      "data": {
        "submission_id": 1
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 5,
    "unread_count": 3
  }
}
```

#### Mark Notifications as Read

```
POST /v1/notifications/mark-read
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Request Body:**
```json
{
  "notification_ids": [1, 2, 3],
  "all": false
}
```

**Response (200 OK):**
```json
{
  "message": "Notifications marked as read successfully",
  "unread_count": 0
}
```

#### Get Unread Notification Count

```
GET /v1/notifications/unread-count
```

**Headers:**
```
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz1234567890
```

**Response (200 OK):**
```json
{
  "unread_count": 3
}
```

## File Downloads

```
GET /download/article/{article_id}/{file_type}
```

**File Type Options:**
- `pdf`: Main PDF document
- `supplementary`: Supplementary materials (ZIP file)

**Query Parameters:**
- `token`: Access token (for public access when needed)

**Response (200 OK):**
Binary file data with appropriate content-type header.

## Error Responses

### 400 Bad Request

```json
{
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

### 401 Unauthorized

```json
{
  "message": "Unauthenticated"
}
```

### 403 Forbidden

```json
{
  "message": "You do not have permission to access this resource"
}
```

### 404 Not Found

```json
{
  "message": "Resource not found"
}
```

### 422 Unprocessable Entity

```json
{
  "message": "The given data was invalid",
  "errors": {
    "email": ["The email has already been taken."]
  }
}
```

### 500 Internal Server Error

```json
{
  "message": "An error occurred on the server",
  "debug": "Error details" // Only in development environment
}
```

## Pagination

Many endpoints return paginated responses. The pagination information is included in the `meta` object:

```json
"meta": {
  "current_page": 1,
  "last_page": 5,
  "per_page": 15,
  "total": 75
}
```

For paginated endpoints, you can use the following query parameters:
- `page`: Page number (default: 1)
- `per_page`: Items per page (default varies by endpoint)

## Rate Limiting

API requests are subject to rate limiting to prevent abuse. The rate limit information is returned in the response headers:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1623764400
```

If you exceed the rate limit, you will receive a 429 Too Many Requests response.

## Implementation Notes for Developers

1. All API requests should include the `Accept: application/json` header.
2. For protected endpoints, include the Bearer token in the Authorization header.
3. All dates are returned in ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ).
4. File uploads should be sent as multipart/form-data.
5. The API uses standard HTTP status codes and follows RESTful principles.
6. For search functionality, consider using the `query` parameter to perform full-text searches.
7. Error responses provide detailed information to help diagnose issues.

## Additional Help

For additional assistance or to report issues with the API, please contact:

Email: api-support@your-journal-domain.com 