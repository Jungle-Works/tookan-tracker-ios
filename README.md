# TookanTracker
Install TookanTracker to see tracking to users of your iPhone app. The TookanTracker is distributed via CocoaPods. This method is documented below:

Pre Requisites :
TookanTracker supports iOS 9.0 and above
Xcode
If you have any queries during the integration, please reach out to us at contact@tookanapp.com

Step 1: Install using CocoaPods
TookanTracker is available through CocoaPods. To add TookanTracker to your project, add the SDK to your Podfile as shown below.

pod 'TookanTracker'

Once you have updated your Podfile run pod install(terminal command) to automatically download and install the SDK in your project.

Please note: TookanTracker supports apps targeting iOS 9.0+. The SDK itself is compatible with all the above iOS 9.0

Upgrading the TrackingSDK?
Run pod update TrackingSDK(terminal command) in your project directory.



Step 2: Initialize SDK
Make sure to initialize the SDK only one time. You can initialize SDK by "import TookanTracker" to your file.

TookanTracker.shared.delegate = self

//
Send MAP_TYPE

TookanTracker.shared.initializeMap(mapType: mapType.text ?? "", key: mapKey.text ?? "")

e.g : TookanTracker.shared.initializeMap(mapType: "FLIGHT_MAP", key: "enter map key")

//

Google API hit for ETA(In second)

TookanTracker.shared.delayTimer = 60.0 ("By passing Double value into it.")


Note:-
if you don't want to use google api hit for ETA and path, then use trackerOptions.setPathUpdateTimer(-1)

By default path update timer is 1 minute.
// Setting up the SDK

TookanTracker.shared.createSession(userID: "\(self.userIdTextField.text ?? "")", isHideUserDetailOnTop: true, completionHandler: { (viewC) in
self.navigationController?.pushViewController(viewC, animated: true)
})
// To Unhide User Detail view set isHideUserDetailOnTop to false
//isHideUserDetailOnTop = false

// By default it is true

TookanTracker.shared.createSession(userID: "Provide Tookan Dashboard User ID",isUINeeded: false, isHideUserDetailOnTop: false, completionHandler: { (viewC) in
    self.navigationController?.pushViewController(viewC, animated: true)
})

 // use to create session.
TookanTracker.shared.startTarckingByJob(sharedSecertId: "tookan-sdk-345#!@", jobId: "Provide Tookan Dashboard JOB ID", userId: "Provide Tookan Dashboard User ID")
//use to fetch response from API.

Step 3: Stop Tracking

You can stop listening location using below method.

TookanTracker.shared.stopTracking()

