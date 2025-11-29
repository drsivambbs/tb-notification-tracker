# Create Admin User Instructions

## Option 1: Using Firebase Console (Easiest)

1. Go to Firebase Console: https://console.firebase.google.com/project/tb-tracker-287ee/firestore

2. Click "Start collection" (or if you already have collections, click "+ Start collection")

3. Enter Collection ID: `users`

4. Click "Next"

5. Enter Document ID: `admin`

6. Add the following fields by clicking "Add field":

   | Field Name | Type | Value |
   |------------|------|-------|
   | user_id | string | admin |
   | password_hash | string | 7676aaafb027c825bd9abab78b234070e702752f625b752e55e55b48e607e358 |
   | role | string | admin_user |
   | phc_name | string | Admin Office |
   | email | string | sivachandran4code@gmail.com |
   | phone_number | string | 9894585495 |
   | created_at | timestamp | (click "Set to current time") |
   | is_active | boolean | true |

7. Click "Save"

8. Done! You can now login at: https://tb-tracker-287ee.web.app
   - User ID: `admin`
   - Password: `admin@123`

## Option 2: Using Node.js Script

If you prefer to use the script:

1. Download Service Account Key:
   - Go to: https://console.firebase.google.com/project/tb-tracker-287ee/settings/serviceaccounts/adminsdk
   - Click "Generate new private key"
   - Save the file as `serviceAccountKey.json` in the `tb_notification_tracker` folder

2. Install firebase-admin:
   ```bash
   npm install firebase-admin
   ```

3. Run the script:
   ```bash
   node create_admin.js
   ```

## Login Credentials

After creating the admin user, you can login with:

- **URL**: https://tb-tracker-287ee.web.app
- **User ID**: admin
- **Password**: admin@123
- **Email**: sivachandran4code@gmail.com
- **Phone**: 9894585495

## Next Steps

After logging in as admin:

1. Create PHC users for each Public Health Center
2. Create STS users for Senior Treatment Supervisors
3. PHC users can start entering TB cases
4. STS users can update case status and Nikshay IDs
5. View analytics on the dashboard

## Security Note

⚠️ **Important**: Change the admin password after first login by:
1. Going to Firebase Console
2. Updating the `password_hash` field with a new hashed password
3. Use a strong password for production use

To generate a new password hash:
```powershell
$password = "your_new_password"; $bytes = [System.Text.Encoding]::UTF8.GetBytes($password); $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes); [System.BitConverter]::ToString($hash).Replace("-","").ToLower()
```
