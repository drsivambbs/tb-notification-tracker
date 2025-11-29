# Progressive Web App (PWA) Setup

This document explains the PWA features implemented in the TB Notification Tracker application.

## Features Implemented

### 1. Web Manifest (Requirements 7.1)

The `web/manifest.json` file configures the PWA with:
- **App Name**: "TB Notification Tracker"
- **Short Name**: "TB Tracker"
- **Theme Color**: #1976D2 (Blue)
- **Background Color**: #ffffff (White)
- **Display Mode**: standalone (full-screen app experience)
- **Icons**: Multiple sizes (192x192, 512x512) including maskable icons
- **Orientation**: portrait-primary
- **Description**: Full app description

### 2. Service Worker (Requirements 7.2, 7.5)

The `web/sw.js` implements:
- **App Shell Caching**: Caches essential files for offline access
- **Cache-First Strategy**: Serves cached content when available
- **Network Fallback**: Fetches from network when cache misses
- **Cache Management**: Automatically cleans up old caches
- **Offline Support**: Returns cached index.html when offline

**Cached Files**:
- index.html
- manifest.json
- favicon.png
- All icon files
- Main application bundle (cached dynamically)

### 3. Offline Detection (Requirements 7.3)

The `OfflineBanner` widget:
- Monitors network connectivity in real-time
- Displays a banner when offline
- Uses `connectivity_plus` package for cross-platform support
- Shows clear message: "You are offline. Some features may not be available."
- Automatically hides when connection is restored

### 4. PWA Installation

The app can be installed on:
- **Desktop**: Chrome, Edge, Safari (macOS)
- **Mobile**: Android (Chrome), iOS (Safari)
- **Installation Prompt**: Browsers show "Install App" prompt automatically

## Testing PWA Features

### Test on Desktop

1. **Build the web app**:
   ```bash
   flutter build web --release
   ```

2. **Serve the app locally**:
   ```bash
   cd build/web
   python -m http.server 8000
   ```
   Or use any local web server.

3. **Open in Chrome**:
   - Navigate to `http://localhost:8000`
   - Look for the install icon in the address bar
   - Click to install the PWA

4. **Test offline mode**:
   - Open Chrome DevTools (F12)
   - Go to Network tab
   - Check "Offline" checkbox
   - Reload the page - app should still work

### Test on Mobile

#### Android:
1. Deploy to Firebase Hosting or any HTTPS server
2. Open in Chrome on Android
3. Tap the menu (⋮) and select "Install app" or "Add to Home screen"
4. The app will be installed like a native app

#### iOS:
1. Deploy to Firebase Hosting or any HTTPS server
2. Open in Safari on iOS
3. Tap the Share button
4. Select "Add to Home Screen"
5. The app will be added to your home screen

### Test Service Worker

1. **Open Chrome DevTools**:
   - Go to Application tab
   - Click "Service Workers" in the left sidebar
   - You should see the service worker registered

2. **Test Caching**:
   - Go to Application > Cache Storage
   - You should see `tb-tracker-shell-v1` and `tb-tracker-v1`
   - Inspect cached files

3. **Test Offline**:
   - Check "Offline" in Network tab
   - Navigate through the app
   - App shell should load from cache

## Deployment for PWA

### Firebase Hosting (Recommended)

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase Hosting**:
   ```bash
   firebase init hosting
   ```
   - Select your project
   - Set public directory to `build/web`
   - Configure as single-page app: Yes
   - Don't overwrite index.html

4. **Build and Deploy**:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

5. **Access your PWA**:
   - Your app will be available at `https://your-project.web.app`
   - HTTPS is required for PWA features

### Other Hosting Options

PWAs require HTTPS. You can deploy to:
- **Netlify**: Drag and drop `build/web` folder
- **Vercel**: Connect GitHub repo
- **GitHub Pages**: Push `build/web` to gh-pages branch
- **AWS S3 + CloudFront**: Upload and configure HTTPS

## PWA Requirements Checklist

- ✅ **Manifest file** with app name, icons, and theme colors (7.1)
- ✅ **Service worker** registered for offline caching (7.2)
- ✅ **Offline detection** with user-friendly message (7.3)
- ✅ **Responsive design** for mobile and desktop (7.4)
- ✅ **App shell caching** strategy implemented (7.5)
- ✅ **HTTPS** required for production deployment
- ✅ **Installable** on mobile and desktop devices

## Troubleshooting

### Service Worker Not Registering

- Ensure you're serving over HTTPS (or localhost)
- Check browser console for errors
- Clear browser cache and reload
- Verify `sw.js` is in the `web` directory

### Install Prompt Not Showing

- PWA must be served over HTTPS
- User must visit the site at least twice
- User must spend at least 30 seconds on the site
- Manifest must be valid (check DevTools > Application > Manifest)

### Offline Mode Not Working

- Check if service worker is active (DevTools > Application > Service Workers)
- Verify files are cached (DevTools > Application > Cache Storage)
- Ensure network is actually offline (DevTools > Network > Offline)
- Check console for service worker errors

### Icons Not Showing

- Verify icon files exist in `web/icons/` directory
- Check manifest.json paths are correct
- Icons must be PNG format
- Recommended sizes: 192x192, 512x512

## Browser Support

- ✅ Chrome/Edge (Desktop & Mobile): Full support
- ✅ Safari (Desktop & Mobile): Full support (iOS 11.3+)
- ✅ Firefox (Desktop & Mobile): Full support
- ⚠️ Internet Explorer: Not supported (use Edge)

## Performance Tips

1. **Minimize Cache Size**: Only cache essential files
2. **Update Strategy**: Implement cache versioning
3. **Background Sync**: Consider for offline data submission
4. **Push Notifications**: Can be added for case updates
5. **Lazy Loading**: Load routes on demand

## Security Considerations

- Always use HTTPS in production
- Service workers have full access to cached data
- Validate all data before caching
- Implement proper authentication checks
- Regular security audits recommended

## Future Enhancements

- **Background Sync**: Queue offline actions
- **Push Notifications**: Notify users of case updates
- **Periodic Background Sync**: Auto-refresh data
- **Share Target**: Share data to the app
- **File Handling**: Open files with the app
