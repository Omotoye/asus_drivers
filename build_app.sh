#!/bin/bash
echo "Building ASUS Control Center..."
cd "$(dirname "$0")"

# Build AppImage
npm run build-appimage

echo ""
echo "✅ Build complete!"
echo "📦 Distributable files are in the 'dist' directory"
echo ""
echo "To install the AppImage:"
echo "1. Navigate to the dist directory"
echo "2. Make the AppImage executable: chmod +x *.AppImage"
echo "3. Run it: ./ASUS-Control-Center-*.AppImage"
