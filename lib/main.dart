name: Android Build
on:
  push:
    branches: [ main ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      - run: rm -rf android
      - run: flutter create . --org com.geek --project-name paytask --platforms=android
      - run: |
          cat > lib/firebase_options.dart << 'EOF'
          import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
          class DefaultFirebaseOptions {
            static FirebaseOptions get currentPlatform => android;
            static const FirebaseOptions android = FirebaseOptions(
              apiKey: 'AIzaSyCMTkOvlF7ieG_bCF4FvJJ34NL5Z-kh3E0',
              appId: '1:897049097953:android:2d3da1fdf1a180997429a0',
              messagingSenderId: '897049097953',
              projectId: 'geek-paytask',
              storageBucket: 'geek-paytask.firebasestorage.app',
            );
          }
          EOF
      - run: |
          mkdir -p android/app
          cat > android/app/google-services.json << 'EOF'
          {
            "project_info": {
              "project_number": "897049097953",
              "project_id": "geek-paytask",
              "storage_bucket": "geek-paytask.firebasestorage.app"
            },
            "client": [
              {
                "client_info": {
                  "mobilesdk_app_id": "1:897049097953:android:2d3da1fdf1a180997429a0",
                  "android_client_info": {
                    "package_name": "com.geek.paytask"
                  }
                },
                "oauth_client": [
                  {
                    "client_id": "897049097953-o592bl4s2n02o0lqmk0pda9c4qkrcacd.apps.googleusercontent.com",
                    "client_type": 3
                  }
                ],
                "api_key": [
                  {
                    "current_key": "AIzaSyCMTkOvlF7ieG_bCF4FvJJ34NL5Z-kh3E0"
                  }
                ],
                "services": {
                  "appinvite_service": {
                    "other_platform_oauth_client": [
                      {
                        "client_id": "897049097953-o592bl4s2n02o0lqmk0pda9c4qkrcacd.apps.googleusercontent.com",
                        "client_type": 3
                      }
                    ]
                  }
                }
              }
            ],
            "configuration_version": "1"
          }
          EOF
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
