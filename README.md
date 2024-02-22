# Flutter Stripe SDK Example

This Flutter application demonstrates the integration of the Stripe SDK for both iOS and Android platforms, showcasing how to process payments within a Flutter app. It communicates with a backend hosted on Render cloud to handle payment processing securely and efficiently.

## Prerequisites

To run this app, you'll need to have the following tools installed on your machine:

- **Flutter**: The project is built using Flutter. If you haven't already, follow the installation guide on the [Flutter official documentation](https://flutter.dev/docs/get-started/install) to set up Flutter on your system.
- **iOS Simulator and Xcode** (for iOS development)
- **Android Emulator and Android Studio** (for Android development)
- **Cocoapods**: Required for installing iOS dependencies.
- A code editor like **VSCode**, **Android Studio**, or **IntelliJ IDEA**.

## Configuration Steps

### 1. Clone the Repository

Start by cloning the repository to your local machine:

```bash
git clone git@github.com:joeariasc/stripe_test.git
```

Navigate into the project directory:
```bash
cd stripe_test
```

### 3. Backend Configuration
This app requires a backend service to process payments. The backend is hosted on Render cloud. Ensure the .env file is correctly configured with your backend's URL to successfully communicate with it. So far, we can use the backend hosted on the Render cloud under this URL 👉🏽 https://stripe-pbr2.onrender.com/
Note. Before starting to make the tests, please make get request (from the browser or the console) just to make sure that the server is alive. It's a free instance so after some quit time the server goes down, so let's activate it!
```
https://stripe-pbr2.onrender.com/api/test
```

You should receive a response like:
```json
{
"message": "Hey"
}
```
Another option could be to set up the backend in your local machine using [Ngrok](https://ngrok.com/docs/). to expose the host. Please check the backend docs to do that. [Stripe Backend](https://github.com/joeariasc/stripe-backend)

### 2. Environment Variables

Copy the example.env file to a .env file. You'll need to update this .env file with your specific backend configurations:
```bash
cp example.env .env
```
Note: Please request the publishable Stripe key to the repo owner (me 🤓)

### 3. Flutter Setup
Ensure Flutter is correctly set up and configured on your machine:

```bash
flutter doctor -v
```

This command checks your environment and displays a report to the terminal window. The Flutter tool automatically downloads platform-specific development binaries as needed.

Fetch all the required Flutter packages:

```bash
flutter pub get
```

### 4. Running the App

#### 4.1 Android
- Start the Android Emulator: Make sure your Android emulator is running.
- Sync Gradle Files: Open Android Studio, navigate to the 'Android' folder of your project, and sync the project with Gradle files. Alternatively, you can run the following command in the terminal:

```bash
cd android && ./gradlew sync && cd ..
```

Run the App: Use Flutter to run the app on your Android emulator:

```bash
flutter run
```

#### 4.2 IOS
- Install iOS Pods: Navigate to the iOS directory of your project and install necessary CocoaPods dependencies:

```bash
cd ios && pod install && cd ..
```

Start the iOS Simulator: Make sure your iOS simulator is running.
Run the App: Use Flutter to run the app on your iOS simulator:

```bash
flutter run
```

## Stripe SDK Integration
The project includes integration with the Stripe SDK for both iOS and Android to facilitate payment processing. Make sure you follow the Stripe documentation to configure the SDK correctly for each platform:

[Stripe iOS SDK Documentation](https://docs.stripe.com/libraries/ios)
[Stripe Android SDK Documentation](https://docs.stripe.com/libraries/android)