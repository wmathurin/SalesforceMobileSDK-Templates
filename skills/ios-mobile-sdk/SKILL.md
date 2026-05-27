---
name: ios-mobile-sdk
description: Comprehensive guide for integrating Salesforce Mobile SDK into iOS Swift applications. Covers creating new apps, adding SDK authentication, SmartStore (encrypted database), MobileSync (cloud sync), and biometric authentication.
---

# iOS Salesforce Mobile SDK Integration

This skill helps you integrate the Salesforce Mobile SDK into iOS Swift applications. It uses progressive disclosure to guide you through the right scenario based on your needs.

## What This Skill Covers

- **Create a new iOS app** with Mobile SDK from scratch
- **Add Mobile SDK** authentication to an existing iOS app
- **Add SmartStore** (encrypted local database) to an app with Mobile SDK
- **Add MobileSync** (cloud data sync) to an app with SmartStore
- **Add Biometric Authentication** (Face ID / Touch ID) to an app with Mobile SDK

---

## Step 1: Identify Your Scenario

**Which of these describes your situation?**

### Scenario A: Create a New App
You're starting from scratch and want to create a new iOS Swift app with Mobile SDK already integrated.

→ **Proceed to [Section: Create New App](#create-new-app)**

### Scenario B: Add SDK to Existing App
You have an existing iOS Swift app and want to add Salesforce authentication.

→ **Proceed to [Section: Add Mobile SDK](#add-mobile-sdk)**

### Scenario C: Add SmartStore
You have an app with Mobile SDK and want to add encrypted local storage (SmartStore).

→ **Proceed to [Section: Add SmartStore](#add-smartstore)**

### Scenario D: Add MobileSync
You have an app with SmartStore and want to add cloud data synchronization.

→ **Proceed to [Section: Add MobileSync](#add-mobilesync)**

### Scenario E: Add Biometric Authentication
You have an app with Mobile SDK and want to add Face ID / Touch ID support.

→ **Proceed to [Section: Add Biometric Auth](#add-biometric-auth)**

---

<a name="create-new-app"></a>
## Create New App

This section creates a new iOS Swift application from scratch using `xcodegen`, then integrates the Salesforce Mobile SDK.

### Prerequisites

Ensure `xcodegen` is installed:

```bash
brew install xcodegen
```

Before starting, gather:
- **App name** (e.g. `MyApp`) — used as the Xcode target name, directory name, and bundle name
- **Bundle ID** (e.g. `com.mycompany.myapp`)
- **Output directory** (where to create the project, e.g. `~/Projects`)
- **Dependency manager**: CocoaPods or Swift Package Manager
- **Consumer Key**, **Callback URL**, **Login host** (or leave as placeholders)

### Step 1: Create the Project Directory and Source Files

```bash
mkdir -p <OutputDir>/<AppName>/<AppName>
cd <OutputDir>/<AppName>
```

Create `<AppName>/AppDelegate.swift`:

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
```

Create `<AppName>/SceneDelegate.swift`:

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
```

Create `<AppName>/LaunchScreen.storyboard`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="15400" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="15404"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 9 format" minToolsVersion="9.0"/>
    </dependencies>
    <scenes>
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                        <viewLayoutGuide key="safeArea" id="Bcu-3y-fUS"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
        </scene>
    </scenes>
</document>
```

### Step 2: Create project.yml for xcodegen

Create `project.yml` in the project root (same level as `<AppName>/`):

```yaml
name: <AppName>
options:
  bundleIdPrefix: <BundleIDPrefix>  # e.g., "com.mycompany"
  deploymentTarget:
    iOS: "18.0"
settings:
  PRODUCT_BUNDLE_IDENTIFIER: <BundleID>
schemes:
  <AppName>:
    build:
      targets:
        <AppName>: all
targets:
  <AppName>:
    type: application
    platform: iOS
    supportedDestinations: [iOS, iPadOS, iOSSimulator]
    settings:
      CODE_SIGN_ENTITLEMENTS: <AppName>/<AppName>.entitlements
      CODE_SIGN_STYLE: Automatic
      CODE_SIGN_IDENTITY: "-"
    sources:
      - <AppName>
    info:
      path: <AppName>/Info.plist
      properties:
        UILaunchStoryboardName: LaunchScreen
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
          UISceneConfigurations:
            UIWindowSceneSessionRoleApplication:
              - UISceneConfigurationName: Default Configuration
                UISceneDelegateClassName: $(PRODUCT_MODULE_NAME).SceneDelegate
```

Replace `<AppName>`, `<BundleIDPrefix>`, and `<BundleID>` with actual values.

> **Why `supportedDestinations`**: On Xcode 16+ the new project model excludes the iOS Simulator from a target's eligible destinations unless this is set explicitly. Without it, `xcodebuild -showdestinations` returns empty and headless / agent builds fail with `Found no destinations for the scheme`.

> **Why a `schemes:` block**: xcodegen otherwise generates a user-only scheme (not in `xcshareddata/xcschemes/`), so `xcodebuild` from the command line can't see it.

> **Why `CODE_SIGN_IDENTITY: "-"` + entitlements file**: Mobile SDK persists OAuth tokens to the keychain, which requires a `keychain-access-groups` entitlement. Entitlements only attach when the app is code-signed — ad-hoc signing (`"-"`) is sufficient on the simulator. **Do not build with `CODE_SIGNING_ALLOWED=NO`** — entitlements get stripped, and login will silently fail with `errSecMissingEntitlement (-34018)` and "access token missing" in the logs.

You'll create the referenced `<AppName>.entitlements` file in the next section ("Add Mobile SDK"). For now, the `project.yml` is ready.

### Step 3: Generate the Xcode Project

```bash
xcodegen generate
```

This creates `<AppName>.xcodeproj`.

> **Important — re-run `xcodegen generate` after adding new files**: xcodegen only picks up files that exist on disk at generation time. Whenever you add a new `.swift`, `.plist`, `.entitlements`, `.storyboard`, or `.json` file to the source folder, re-run `xcodegen generate` so the Xcode project includes it. This applies to both SPM and CocoaPods projects.
>
> **CocoaPods only**: `xcodegen generate` regenerates the `.xcodeproj` file, which breaks the CocoaPods workspace integration. Run `pod install` after every regeneration. The workflow is: `xcodegen generate` → add new files → `xcodegen generate` → `pod install`.

### Step 4: Add Mobile SDK

Now that you have a bare iOS app, proceed to the [Add Mobile SDK](#add-mobile-sdk) section below to integrate Salesforce authentication. After completing the "Add Mobile SDK" section, remember to run `xcodegen generate` followed by `pod install` to include any new files you created.

---

<a name="add-mobile-sdk"></a>
## Add Mobile SDK

This section integrates the Salesforce Mobile SDK into an existing iOS Swift application, wiring up authentication so users are prompted to log in to Salesforce when the app launches.

### Prerequisites

Before starting, gather:
- **App target name** (the Xcode target to modify, e.g. `MyApp`)
- **Consumer Key** (OAuth connected app consumer key, or leave as placeholder)
- **Callback URL** (OAuth redirect URI, or leave as placeholder)
- **Login host** (default: `login.salesforce.com`, use `test.salesforce.com` for sandboxes)

Also detect which dependency manager the project uses:
- Project has a `Podfile` → use the CocoaPods path
- Project has `.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/` → use the SPM path

### Step 1: Add the SDK Dependency

#### Option A — CocoaPods (project has a `Podfile`)

Add the Salesforce specs source and `SalesforceSDKCore` pod. `SalesforceSDKCore` pulls in `SalesforceAnalytics` and `SalesforceSDKCommon` transitively.

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs'

platform :ios, '18.0'

target 'YourApp' do
  use_frameworks!
  pod 'SalesforceSDKCore'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
    end
  end
end
```

Then install:

```bash
pod install
```

Open `YourApp.xcworkspace` (not `.xcodeproj`) from now on.

#### Option B — Swift Package Manager (project uses SPM)

In Xcode:
1. **File → Add Package Dependencies…**
2. Enter: `https://github.com/forcedotcom/SalesforceMobileSDK-iOS-SPM`
3. Select branch `master` (or the version tag matching your desired SDK release)
4. Add these products to your app target:
   - `SalesforceSDKCore`
   - `SalesforceAnalytics`
   - `SalesforceSDKCommon`

### Step 2: Add LaunchScreen.storyboard (if not already present)

Without a launch storyboard, iOS does not properly establish the window's safe-area bounds before the SDK presents its login screen.

If the app doesn't already have `LaunchScreen.storyboard`, create it in the app target's source folder (see the XML above in the "Create New App" section).

Add `LaunchScreen.storyboard` to the Xcode target's **Copy Bundle Resources** build phase.

### Step 3: Create InitialViewController.swift

Create `InitialViewController.swift` inside the app target's source folder. This is the splash screen that fills the window while the SDK presents the login flow.

```swift
import UIKit

class InitialViewController: UIViewController {}
```

Add the file to the Xcode target.

### Step 4: Update AppDelegate.swift

Add the SDK initialization:

```swift
import UIKit
import SalesforceSDKCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    override init() {
        super.init()
        SalesforceManager.initializeSDK()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
```

### Step 5: Update SceneDelegate.swift

Wire up the authentication flow:

```swift
import UIKit
import SalesforceSDKCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        AuthHelper.registerBlock(forCurrentUserChangeNotifications: {
            self.resetViewState {
                self.setupRootViewController()
            }
        })
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        initializeAppViewState()
        AuthHelper.loginIfRequired {
            self.setupRootViewController()
        }
    }

    // MARK: - Private

    func initializeAppViewState() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.initializeAppViewState() }
            return
        }
        window?.rootViewController = InitialViewController(nibName: nil, bundle: nil)
        window?.makeKeyAndVisible()
    }

    func setupRootViewController() {
        // Smoke test UI - replace with your actual root view controller
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Mobile SDK ready"
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        window?.rootViewController = vc
    }

    func resetViewState(_ postResetBlock: @escaping () -> Void) {
        if let root = window?.rootViewController, root.presentedViewController != nil {
            root.dismiss(animated: false, completion: postResetBlock)
        } else {
            postResetBlock()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
```

### Step 6: Add bootconfig.plist

Create `bootconfig.plist` inside your app target's source folder (next to `Info.plist`), then add it to the Xcode target.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>remoteAccessConsumerKey</key>
    <string>YOUR_CONSUMER_KEY</string>
    <key>oauthRedirectURI</key>
    <string>YOUR_CALLBACK_URL</string>
    <key>shouldAuthenticate</key>
    <true/>
</dict>
</plist>
```

Replace `YOUR_CONSUMER_KEY` and `YOUR_CALLBACK_URL` with actual values (or leave as placeholders).

Verify `bootconfig.plist` appears in the **Copy Bundle Resources** build phase.

### Step 7: Update Info.plist

Add the following keys to the app target's `Info.plist`:

```xml
<key>SFDCOAuthLoginHost</key>
<string>login.salesforce.com</string>
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

Use the login host provided by the user, or `login.salesforce.com` as the default.

### Step 8: Add the Keychain Entitlements File

**This step is required.** Mobile SDK persists OAuth access and refresh tokens in the iOS keychain, which requires the app to declare a `keychain-access-groups` entitlement. Without it, login appears to succeed in the UI but the SDK cannot store tokens — auth then fails silently with `errSecMissingEntitlement (-34018)` and `Authentication failed: ... access token` in the device logs, and your post-login UI never appears.

Create `<AppName>.entitlements` inside the app target's source folder (next to `Info.plist`):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)<BundleID></string>
    </array>
</dict>
</plist>
```

Replace `<BundleID>` with the same value used in `project.yml` (e.g. `com.mycompany.myapp`).

If you used the `project.yml` template from "Create New App", `CODE_SIGN_ENTITLEMENTS` already points at this file. If you're integrating into an existing project, set **Code Signing Entitlements** in Build Settings to `<AppName>/<AppName>.entitlements`, or under **Signing & Capabilities** add the **Keychain Sharing** capability and add a group matching your bundle ID.

After adding the file, run `xcodegen generate` so the project picks it up.

### Step 9: Build and Verify

Build and run. On first launch, the Salesforce login screen should appear. After successful login, you should see **"Mobile SDK ready"**.

> **Do not pass `CODE_SIGNING_ALLOWED=NO`** to `xcodebuild`. It strips the entitlements file from the built `.app`, the keychain calls fail with `-34018`, and login fails silently with no user-visible error. For headless / CI builds on the simulator, ad-hoc signing (`CODE_SIGN_IDENTITY=-`, the default in the template) is the right choice.

---

<a name="add-smartstore"></a>
## Add SmartStore

This section adds the Salesforce SmartStore encrypted local database to an existing iOS Swift app that already has `SalesforceSDKCore` integrated.

### Prerequisites

**The app must already have the Mobile SDK wired up.** Check `AppDelegate.swift` for `SalesforceManager.initializeSDK()` and that `bootconfig.plist` exists. If not, complete the [Add Mobile SDK](#add-mobile-sdk) section first.

Before starting, confirm:
- **App target name** (e.g. `MyApp`)
- **Soup name** for the initial store table (default: `Item`)
- Which dependency manager is in use (CocoaPods vs SPM)

### Step 1: Add the SmartStore Dependency

#### Option A — CocoaPods

Replace `SalesforceSDKCore` pod with `SmartStore` (SmartStore depends on SalesforceSDKCore transitively):

**Before:**
```ruby
pod 'SalesforceSDKCore'
```

**After:**
```ruby
pod 'SmartStore'
```

Then run:

```bash
pod install
```

#### Option B — Swift Package Manager

In Xcode, add the `SmartStore` product from the `SalesforceMobileSDK-iOS-SPM` package to the app target's **Frameworks, Libraries, and Embedded Content**.

### Step 2: Upgrade the SDK Manager in AppDelegate.swift

**Before:**
```swift
import SalesforceSDKCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        super.init()
        SalesforceManager.initializeSDK()
    }
    // ...
}
```

**After:**
```swift
import SmartStore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        super.init()
        SmartStoreSDKManager.initializeSDK()
    }
    // ...
}
```

### Step 3: Set Up the Store After Login in SceneDelegate.swift

Add a `SmartStore` import and call `setupUserStoreFromDefaultConfig()` inside `setupRootViewController()`:

**Before:**
```swift
import SalesforceSDKCore

// ...

func setupRootViewController() {
    window?.rootViewController = UIViewController()
}
```

**After:**
```swift
import SmartStore
import SalesforceSDKCore   // keep this — AuthHelper lives here

// ...

func setupRootViewController() {
    SmartStoreSDKManager.shared.setupUserStoreFromDefaultConfig()
    let vc = UIViewController()
    vc.view.backgroundColor = .systemBackground
    let label = UILabel()
    label.text = "SmartStore ready"
    label.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(label)
    NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
    ])
    window?.rootViewController = vc
}
```

### Step 4: Create userstore.json

Create `userstore.json` inside the app target's source folder:

```json
{
  "soups": [
    {
      "soupName": "<SoupName>",
      "indexes": [
        { "path": "Id",        "type": "string" },
        { "path": "Name",      "type": "string" },
        { "path": "__local__", "type": "string" }
      ]
    }
  ]
}
```

Replace `<SoupName>` with the soup name (default: `Item`).

Add `userstore.json` to the Xcode target and verify it appears in **Copy Bundle Resources**.

### Step 5: Build and Verify

Build and run. After login, you should see **"SmartStore ready"**.

---

<a name="add-mobilesync"></a>
## Add MobileSync

This section adds the Salesforce MobileSync cloud data synchronization library to an existing iOS Swift app that already has `SmartStore` integrated.

### Prerequisites

**The app must already have SmartStore wired up.** Check `AppDelegate.swift` for `SmartStoreSDKManager.initializeSDK()` and that `userstore.json` exists. If not, complete the [Add SmartStore](#add-smartstore) section first.

Before starting, gather:
- **App target name** (e.g. `MyApp`)
- **Soup name** to sync (must match a soup in `userstore.json`, e.g. `Item`)
- **Salesforce sObject type** to sync (e.g. `Contact`, `Account`, `CustomObject__c`)
- Which dependency manager is in use (CocoaPods vs SPM)

### Step 1: Add the MobileSync Dependency

#### Option A — CocoaPods

Replace `SmartStore` pod with `MobileSync` (MobileSync depends on SmartStore transitively):

**Before:**
```ruby
pod 'SmartStore'
```

**After:**
```ruby
pod 'MobileSync'
```

Then run:

```bash
pod install
```

#### Option B — Swift Package Manager

In Xcode, add the `MobileSync` product from the `SalesforceMobileSDK-iOS-SPM` package to the app target's **Frameworks, Libraries, and Embedded Content**.

### Step 2: Upgrade the SDK Manager in AppDelegate.swift

**Before:**
```swift
import SmartStore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        super.init()
        SmartStoreSDKManager.initializeSDK()
    }
    // ...
}
```

**After:**
```swift
import MobileSync

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        super.init()
        MobileSyncSDKManager.initializeSDK()
    }
    // ...
}
```

### Step 3: Set Up Sync After Login in SceneDelegate.swift

Add a `MobileSync` import and call `setupUserSyncFromDefaultConfig()`, then perform an initial sync:

**Before:**
```swift
import SmartStore
import SalesforceSDKCore

// ...

func setupRootViewController() {
    SmartStoreSDKManager.shared.setupUserStoreFromDefaultConfig()
    // ... UI setup
}
```

**After:**
```swift
import MobileSync
import SalesforceSDKCore

// ...

func setupRootViewController() {
    MobileSyncSDKManager.shared.setupUserStoreFromDefaultConfig()
    MobileSyncSDKManager.shared.setupUserSyncsFromDefaultConfig()
    
    // Perform initial sync (optional, for demonstration)
    if let syncManager = SFSyncManager.sharedInstance(for: SFUserAccountManager.shared().currentUser) {
        let target = SFSoqlSyncDownTarget(query: "SELECT Id, Name FROM <SObjectType>")
        let options = SFSyncOptions.newSyncOptions(forSyncDown: .overwrite)
        let sync = try? syncManager.syncDown(target: target, soupName: "<SoupName>", options: options) { _ in
            print("Initial sync complete")
        }
    }
    
    let vc = UIViewController()
    vc.view.backgroundColor = .systemBackground
    let label = UILabel()
    label.text = "SmartStore + MobileSync ready"
    label.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(label)
    NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
    ])
    window?.rootViewController = vc
}
```

Replace `<SObjectType>` and `<SoupName>` with actual values (e.g. `Contact` and `Item`).

### Step 4: Create usersync.json

Create `usersync.json` inside the app target's source folder:

```json
{
  "syncs": [
    {
      "syncType": "syncDown",
      "soupName": "<SoupName>",
      "target": {
        "type": "soql",
        "query": "SELECT Id, Name FROM <SObjectType>"
      },
      "options": {
        "mergeMode": "OVERWRITE"
      }
    }
  ]
}
```

Replace `<SoupName>` and `<SObjectType>` with actual values.

Add `usersync.json` to the Xcode target and verify it appears in **Copy Bundle Resources**.

### Step 5: Build and Verify

Build and run. After login, you should see **"SmartStore + MobileSync ready"** and data should begin syncing from Salesforce.

---

<a name="add-biometric-auth"></a>
## Add Biometric Authentication

This section adds Face ID / Touch ID biometric authentication to an existing iOS Swift app that already has Mobile SDK integrated.

### Prerequisites

**The app must already have the Mobile SDK wired up.** Check `AppDelegate.swift` for `SalesforceManager.initializeSDK()` (or one of its subclasses) and that `bootconfig.plist` exists. If not, complete the [Add Mobile SDK](#add-mobile-sdk) section first.

Before starting, confirm:
- **App target name** (e.g. `MyApp`)
- **Biometric policy**: `deviceOwner` (Face ID / Touch ID / passcode fallback) or `deviceOwnerAuthenticationWithBiometrics` (biometric only, no passcode fallback)

### Step 1: Update Info.plist for Biometric Permissions

Add the Face ID usage description to `Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID to verify your identity before accessing Salesforce data.</string>
```

### Step 2: Configure Biometric Authentication in AppDelegate.swift

Add biometric configuration after SDK initialization:

```swift
import UIKit
import SalesforceSDKCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    override init() {
        super.init()
        SalesforceManager.initializeSDK()
        
        // Configure biometric authentication
        BiometricAuthenticationManager.shared.biometricAuthenticationEnabled = true
        BiometricAuthenticationManager.shared.biometricAuthenticationPolicy = .deviceOwner
    }
    
    // ... rest of AppDelegate
}
```

Use `.deviceOwner` for Face ID / Touch ID with passcode fallback, or `.deviceOwnerAuthenticationWithBiometrics` for biometric-only (no passcode fallback).

### Step 3: Prompt for Biometric Enrollment After Login

In `SceneDelegate.swift`, add biometric enrollment prompt after successful login:

```swift
func setupRootViewController() {
    // Show biometric opt-in if not already configured
    if !BiometricAuthenticationManager.shared.locked {
        BiometricAuthenticationManager.shared.showBiometricEnrollment(presentingController: nil) { enrolled in
            if enrolled {
                print("User opted in to biometric authentication")
            }
        }
    }
    
    // ... rest of setupRootViewController
}
```

### Step 4: Build and Verify

Build and run. After login, the app should prompt the user to enable Face ID / Touch ID. On subsequent launches, the user will need to authenticate biometrically before accessing the app.

---

## Troubleshooting

### Build Errors

**`Cannot find type 'SalesforceManager'` (or `SmartStoreSDKManager`, `MobileSyncSDKManager`)**
The import is missing or the framework is not linked. For CocoaPods, verify `pod install` completed and you opened `.xcworkspace`. For SPM, verify the product is in the target's Frameworks.

**`pod install` fails with "Unable to find a specification"**
Ensure both sources are declared in the Podfile — `cdn.cocoapods.org` and `github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs`.

### Login Issues

**Login screen does not appear**
Check that `SFDCOAuthLoginHost` is in `Info.plist` and `bootconfig.plist` is included in Copy Bundle Resources.

**Login screen has black bars above and below it**
`LaunchScreen.storyboard` is missing or not set in `Info.plist` as `UILaunchStoryboardName`.

**Login screen accepts credentials but the app never advances to its post-login UI**
The keychain entitlement is missing or has been stripped by the build. In Console / `xcrun simctl spawn <udid> log show ...` you will see `errSecMissingEntitlement` / OSStatus `-34018` and `Authentication failed: ... access token`. Verify (a) `<AppName>.entitlements` exists with a `keychain-access-groups` entry matching the bundle ID, (b) Build Settings → **Code Signing Entitlements** points at it, and (c) the build is **not** using `CODE_SIGNING_ALLOWED=NO` (which strips entitlements). Ad-hoc signing (`CODE_SIGN_IDENTITY=-`) is sufficient on the simulator.

**`xcodebuild` fails with "Found no destinations for the scheme"**
The target is missing `supportedDestinations` (Xcode 16+ excludes the simulator by default), or the scheme is not shared. In `project.yml`, add `supportedDestinations: [iOS, iPadOS, iOSSimulator]` to the target and a top-level `schemes:` block, then re-run `xcodegen generate`.

### SmartStore Issues

**`setupUserStoreFromDefaultConfig()` silently does nothing**
`userstore.json` is missing from Copy Bundle Resources. Open Build Phases and add it.

### Biometric Issues

**Biometric prompt does not appear**
Verify `NSFaceIDUsageDescription` is in `Info.plist` and `BiometricAuthenticationManager.shared.biometricAuthenticationEnabled` is set to `true`.

---

## Next Steps

Once you've completed the integration:
- Replace placeholder OAuth values in `bootconfig.plist` with real Connected App credentials
- Replace smoke test UI with your actual app screens
- Implement data sync logic for your specific use case
- Test on physical devices for biometric authentication
