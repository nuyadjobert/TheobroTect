# # Stage 1 : Flutter Build Environment
# FROM ghcr.io/cirruslabs/flutter:3.41.0 AS builder

# WORKDIR /app

# # Copy dependency files first for Docker layer caching
# COPY pubspec.yaml .
# COPY pubspec.lock .

# RUN flutter pub get

# # Copy the rest of the project
# COPY . .

# # Optional: verify Flutter installation
# RUN flutter doctor -v

# # Build release APK
# RUN flutter build apk --release

# # Stage 2 : Export APK
# FROM alpine

# WORKDIR /output

# COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk .