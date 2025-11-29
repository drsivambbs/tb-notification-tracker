# Firestore Security Rules

This document explains the Firestore security rules implemented for the TB Notification Tracker application.

## Overview

The security rules enforce role-based access control (RBAC) for three user types:
- **Admin Users** (`admin_user`): Full access to all data
- **STS Users** (`sts_user`): Can read and update cases from their assigned PHC
- **PHC Users** (`phc_user`): Can read cases from their own PHC and create new cases

## Users Collection Rules

### Read Access
- All authenticated users can read user documents
- This allows the application to fetch user profiles and display user information

### Write Access
- Only admin users can create, update, or delete user documents
- This ensures only administrators can manage user accounts

## Cases Collection Rules

### Read Access (Requirements 10.4)
Role-based read access is enforced:

1. **Admin Users**: Can read all cases from all PHCs
2. **PHC Users**: Can only read cases where `phc_name` matches their assigned PHC
3. **STS Users**: Can only read cases where `phc_name` matches their assigned PHC

All users must be authenticated and active (`is_active == true`).

### Create Access
- Only PHC users can create new cases
- The `phc_name` must match the user's assigned PHC
- The `created_by_user_id` must match the authenticated user's ID
- The `case_status` must be set to "Processing" on creation
- User must be active

### Update Access (Requirements 10.5)
STS users can update cases with field-level restrictions:

1. Case must be from their assigned PHC (`phc_name` matches)
2. Only these fields can be updated:
   - `case_status`
   - `nikshay_id`
   - `status_updated_by`
   - `status_updated_at`
3. The `status_updated_by` field must be set to the current user's ID
4. The `status_updated_at` field must be set to a timestamp
5. User must be active

**All other fields are read-only for STS users**, including:
- Patient information (name, age, gender, phone)
- PHC information
- Creation metadata

### Delete Access
- Only admin users can delete cases
- This is for data management purposes

## Helper Functions

The rules use several helper functions:

- `isAuthenticated()`: Checks if user is logged in
- `getUserData()`: Fetches user data from Firestore
- `isAdmin()`: Checks if user has admin role
- `isPhcUser()`: Checks if user has PHC role
- `isStsUser()`: Checks if user has STS role
- `isActiveUser()`: Checks if user account is active

## Deployment

### Using Firebase CLI

1. Install Firebase CLI if not already installed:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in your project (if not already done):
   ```bash
   firebase init firestore
   ```
   - Select your Firebase project
   - Accept the default `firestore.rules` file

4. Deploy the security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to Firestore Database
4. Click on the "Rules" tab
5. Copy the contents of `firestore.rules` and paste into the editor
6. Click "Publish"

## Testing Security Rules

You can test the security rules using the Firebase Emulator Suite:

1. Install the Firebase Emulator:
   ```bash
   firebase init emulators
   ```
   Select "Firestore Emulator"

2. Start the emulator:
   ```bash
   firebase emulators:start
   ```

3. Run your tests against the emulator

## Important Notes

1. **User Authentication**: The rules assume users are authenticated using Firebase Auth with their `user_id` as the UID
2. **Active Users Only**: Only active users (`is_active == true`) can perform operations
3. **PHC Scoping**: All data access is scoped by PHC name to ensure data isolation
4. **Audit Trail**: STS users must set `status_updated_by` and `status_updated_at` when updating cases
5. **Field-Level Security**: STS users can only modify specific fields, ensuring data integrity

## Security Considerations

- Rules are evaluated on every request, providing real-time security
- Client-side validation should match server-side rules for better UX
- Rules prevent unauthorized access even if client code is compromised
- Regular security audits are recommended
- Monitor Firebase usage for suspicious activity

## Troubleshooting

If you encounter permission errors:

1. Verify the user is authenticated
2. Check the user's role in Firestore
3. Ensure the user's `is_active` field is `true`
4. Verify the PHC name matches for PHC/STS users
5. Check that STS users are only updating allowed fields
6. Review Firebase Console logs for detailed error messages
