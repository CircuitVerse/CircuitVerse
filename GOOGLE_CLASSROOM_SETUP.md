# Google Classroom Integration - Setup Complete

## Changes Made

### 1. Updated OAuth Scopes
**File:** `config/initializers/devise.rb`
- Added required Google Classroom API scopes
- Set `prompt: 'consent'` to force re-authentication
- Added `access_type: 'offline'` to get refresh tokens
- Added `include_granted_scopes: true` for incremental authorization

### 2. Fixed Token Persistence
**File:** `app/controllers/users/omniauth_callbacks_controller.rb`
- Updated to only save tokens when present (prevents overwriting refresh_token with nil)
- Added proper token expiration handling

### 3. Updated Google Classroom Service
**File:** `app/services/google_classroom_service.rb`
- Added all required OAuth scopes for grade submission
- Added automatic token refresh logic
- Added `submit_grade` method for syncing grades to Google Classroom
- Added `get_student_submissions` method

### 4. Created Rake Task
**File:** `lib/tasks/google_classroom.rake`
- Task to clear old tokens and force re-authentication

## Next Steps

### Step 1: Clear Old Tokens
Run this command to clear existing tokens:
```bash
rake google_classroom:clear_tokens
```

### Step 2: Restart Server
```bash
# Stop your server (Ctrl+C)
# Then restart
rails server
```

### Step 3: Re-authenticate
1. Sign out of CircuitVerse
2. Sign in with Google again
3. You'll see a new consent screen with Classroom permissions
4. Accept the permissions

### Step 4: Verify
Visit `/google_classroom_test` to verify:
- `has_tokens: true`
- `api_test: { success: true }`

### Step 5: Test Integration
1. Go to `/google_classroom`
2. Import a course
3. Sync assignments
4. Grade some assignments
5. Click "Sync Grades to Google Classroom"

## Google Cloud Console Setup

Make sure these scopes are added in Google Cloud Console:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. APIs & Services → OAuth consent screen
3. Edit App → Scopes
4. Add these scopes:
   - `../auth/userinfo.email`
   - `../auth/userinfo.profile`
   - `../auth/classroom.courses.readonly`
   - `../auth/classroom.coursework.students`
   - `../auth/classroom.coursework.students.readonly`

## Troubleshooting

### Still getting PERMISSION_DENIED?
1. Make sure Google Classroom API is enabled in Google Cloud Console
2. Clear browser cookies and try again
3. Revoke access at https://myaccount.google.com/permissions
4. Sign in again

### Tokens not being saved?
Check if columns exist:
```bash
rails runner "puts User.column_names.grep(/google/)"
```

Should show:
- google_access_token
- google_refresh_token
- google_classroom_id
