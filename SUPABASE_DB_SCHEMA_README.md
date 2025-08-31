# Supabase Database Schema Guide

This guide describes the recommended Supabase database schema for your app, based on your Dart models. Use this as a reference when creating tables and relationships in Supabase.

---

## 1. `users` Table
**Purpose:** Stores basic user information and authentication status.

| Column         | Type      | Description                |
|---------------|-----------|----------------------------|
| uid           | text      | Unique user ID (PK)        |
| email         | text      | User email                 |
| first_name    | text      | First name                 |
| middle_name   | text      | Middle name                |
| last_name     | text      | Last name                  |
| email_verified| boolean   | Email verified status      |
| user_type     | text      | Enum: teacher, parent, student, learner |

---

## 2. `teachers` Table
**Purpose:** Stores teacher-specific profile data.

| Column      | Type      | Description                |
|-------------|-----------|----------------------------|
| uid         | text      | FK to users.uid (PK)       |
| email       | text      | FK to users.email          |
| first_name  | text      |                            |
| middle_name | text      |                            |
| last_name   | text      |                            |
| subjects    | text[]    | Array of subjects          |
| profile_pic | text      | URL to profile picture     |
| address     | text      |                            |
| city        | text      |                            |
| state       | text      |                            |
| country     | text      |                            |
| pincode     | text      |                            |
| phone_number| text      |                            |
| gender      | text      |                            |
| dob         | date      | Date of birth              |
| work_exp    | text      | Work experience            |
| resume      | text      | URL to resume              |
| board       | text[]    | Array of boards            |
| usertype    | text      | Enum: teacher              |

---

## 3. `parents` Table
**Purpose:** Stores parent-specific profile data.

| Column      | Type      | Description                |
|-------------|-----------|----------------------------|
| uid         | text      | FK to users.uid (PK)       |
| email       | text      | FK to users.email          |
| first_name  | text      |                            |
| middle_name | text      |                            |
| last_name   | text      |                            |
| occupation  | text      |                            |
| profile_pic | text      | URL to profile picture     |
| address     | text      |                            |
| city        | text      |                            |
| state       | text      |                            |
| country     | text      |                            |
| pincode     | text      |                            |
| phone_number| text      |                            |
| gender      | text      |                            |
| dob         | date      | Date of birth              |
| usertype    | text      | Enum: parent               |

---

## 4. `students` Table
**Purpose:** Stores student-specific profile data.

| Column      | Type      | Description                |
|-------------|-----------|----------------------------|
| uid         | text      | FK to users.uid (PK)       |
| email       | text      | FK to users.email          |
| first_name  | text      |                            |
| middle_name | text      |                            |
| last_name   | text      |                            |
| email_verified| boolean |                            |
| parent_uid  | text      | FK to parents.uid          |
| standard    | text      |                            |
| subjects    | text[]    | Array of subjects          |
| board       | text      |                            |
| medium      | text      |                            |

---

## 5. `language_learners` Table
**Purpose:** Stores language learner profile data.

| Column           | Type      | Description                |
|------------------|-----------|----------------------------|
| uid              | text      | FK to users.uid (PK)       |
| email            | text      | FK to users.email          |
| first_name       | text      |                            |
| middle_name      | text      |                            |
| last_name        | text      |                            |
| email_verified   | boolean   |                            |
| profile_pic      | text      | URL to profile picture     |
| gender           | text      |                            |
| dob              | date      | Date of birth              |
| occupation       | text      |                            |
| phone_number     | text      |                            |
| address          | text      |                            |
| city             | text      |                            |
| state            | text      |                            |
| country          | text      |                            |
| pincode          | text      |                            |
| languages_known  | text[]    | Array of known languages   |
| languages_to_learn| text[]   | Array of target languages  |

---

## Relationships
- `users.uid` is the primary key for all user types.
- `teachers`, `parents`, `students`, and `language_learners` reference `users.uid`.
- `students.parent_uid` references `parents.uid`.

---

## Notes
- Use Supabase Auth for authentication; link `uid` to Supabase user ID.
- Use `text[]` for arrays (subjects, boards, languages).
- Store file URLs (profile pics, resumes) as text.
- Adjust types as needed for your app logic.

---

## Example Table Creation (Postgres SQL)
```sql
CREATE TABLE users (
  uid text PRIMARY KEY,
  email text NOT NULL,
  first_name text,
  middle_name text,
  last_name text,
  email_verified boolean,
  user_type text
);

CREATE TABLE teachers (
  uid text PRIMARY KEY REFERENCES users(uid),
  email text,
  first_name text,
  middle_name text,
  last_name text,
  subjects text[],
  profile_pic text,
  address text,
  city text,
  state text,
  country text,
  pincode text,
  phone_number text,
  gender text,
  dob date,
  work_exp text,
  resume text,
  board text[],
  usertype text
);
-- Repeat for parents, students, language_learners
```

---

**Edit this file as your models evolve!**
