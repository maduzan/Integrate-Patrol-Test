# widget_test

A Flutter project demonstrating integration and UI testing using **Patrol**.

---

## 🚀 Steps to Implement Patrol Tests From the Beginning

Follow these step-by-step instructions to set up Patrol for both Android and iOS in any Flutter project.

---

### Step 1: Install the Patrol CLI (One-time machine setup)

Install the Patrol CLI globally using `pub`:

```bash
flutter pub global activate patrol_cli
```

---

### Step 2: Ensure Environment Variables are in your System PATH

Ensure Android SDK tools and global pub binaries are accessible in your terminal. Add these lines to your `~/.zshrc` (macOS default):

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
```

Reload your terminal configuration:

```bash
source ~/.zshrc
```

---

### Step 3: Verify Setup

Run the Patrol doctor check:

```bash
patrol doctor
```

Verify that Android SDK and iOS tools show green checkmarks.

---

### Step 4: Add Dependencies & Configuration to `pubspec.yaml`

1. Add `patrol` and `patrol_finders` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  patrol: ^4.10.0
  patrol_finders: ^3.6.0
```

2. At the very bottom of `pubspec.yaml` (root level, unindented), add the `patrol` configuration block:

```yaml
patrol:
  app_name: "Color Change App"
  android:
    package_name: "com.example.colorchangeapp"
  ios:
    bundle_id: "com.example.colorchangeapp"
```

3. Fetch packages:

```bash
flutter pub get
```

---

### Step 5: Configure Android

#### 5.1 Update `android/app/build.gradle.kts`
Ensure `defaultConfig`, `testOptions`, and `dependencies` are configured:

```kotlin
android {
    namespace = "com.example.colorchangeapp"

    defaultConfig {
        applicationId = "com.example.colorchangeapp"
        minSdk = 21 // Patrol requires minSdk 21 or higher
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Patrol JUnit runner:
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }

    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }
}

dependencies {
    androidTestUtil("androidx.test:orchestrator:1.5.1")
}
```

#### 5.2 Create the Test Class
Create the file `MainActivityTest.java` under:
`android/app/src/androidTest/java/com/example/colorchangeapp/MainActivityTest.java`

```java
package com.example.colorchangeapp;

import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.PatrolJUnitRunner;

@RunWith(Parameterized.class)
public class MainActivityTest {

    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.runDartTest(dartTestName);
    }
}
```

---

### Step 6: Configure iOS

#### 6.1 Open Xcode Workspace
Always open `.xcworkspace` (never `.xcodeproj`):

```bash
open ios/Runner.xcworkspace
```

#### 6.2 Add UI Testing Bundle Target
1. In the top Xcode menu, click **File > New > Target...**
2. Select the **iOS** tab, choose **UI Testing Bundle**, and click **Next**.
3. Configure the target:
   - **Product Name:** `RunnerUITests`
   - **Language:** `Objective-C` *(Required for Patrol macro)*
   - **Organization Identifier:** `com.example.colorchangeapp`
   - **Target to be Tested:** `Runner`
4. Click **Finish**. (If an "Activate Scheme" popup appears, click **Activate**).

#### 6.3 Clean Up Generated Files
In Xcode's Project Navigator on the left, under `RunnerUITests`:
- If `RunnerUITestsLaunchTests.m` was created, delete it (Right-click > Delete > Move to Trash).

#### 6.4 Update `RunnerUITests.m`
Open `RunnerUITests.m` and replace its entire content with:

```objc
@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
```

#### 6.5 Update `ios/Podfile`
In `ios/Podfile`, add `target 'RunnerUITests'` inside the main `target 'Runner'` block:

```ruby
target 'Runner' do
  use_frameworks!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end

  # Add this block:
  target 'RunnerUITests' do
    inherit! :complete
  end
end
```

Then run in your terminal:
```bash
cd ios && pod install && cd ..
```

#### 6.6 Crucial iOS Troubleshooting Settings
To avoid build failures and ensure tests run visibly on screen:
1. **Disable User Script Sandboxing:** In `Runner.xcodeproj` build settings for `RunnerUITests`, ensure `ENABLE_USER_SCRIPT_SANDBOXING = NO`.
2. **Set Deployment Target:** Ensure the iOS Deployment Target for `RunnerUITests` matches `Runner` (e.g., `15.0`).
3. **Disable Parallel Testing (To see tests live on screen):**
   - In Xcode: **Product > Scheme > Edit Scheme... > Test > Info tab**.
   - Make sure **"Execute in parallel"** is **UNCHECKED** (or set `parallelizable = "NO"` in `Runner.xcscheme`).

---

### Step 7: Write Your First Patrol Test

Create a file named `patrol_test/app_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:widget_test/main.dart';

void main() {
  patrolTest(
    'taps "Change to Red" button and verifies color change',
    ($) async {
      await $.pumpWidgetAndSettle(const MaterialApp(home: ColorChangeApp()));

      expect($('Change to Red'), findsOneWidget);

      await $('Change to Red').tap();

      final updatedBox = $.tester.widget<Container>($(const Key('color_box')));
      expect(updatedBox.color, Colors.red);
    },
  );
}
```

---

### Step 8: Run Your Tests

Make sure an emulator or simulator is running, then run:

```bash
# Run on Android Emulator or iOS Simulator:
patrol test --target patrol_test/app_test.dart

# Or target a specific device:
patrol test --target patrol_test/app_test.dart -d "iPhone 18 Pro"
```
