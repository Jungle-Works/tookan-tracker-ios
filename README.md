Install TrackingSDK to see tracking to users of your iPhone app. The TrackingSDK is distributed via CocoaPods. This method is documented below:

Pre Requisites :
TrackingSdk supports iOS 9.0 and above
Xcode 10.2 and above

Step 1: Clone or Download the SDK

Step 2: Add TookanTracker.framework, GoogleMaps.bundle and GooglePlaces.bundle framework to you project.

Step 3: Select Target then your app. Under General tab go to Frameworks, libraries, and Embedded Content, then select TookanTracker.framework under Embed deselect Do Not Embed and select other option.

Step 4: In you project info.plist file add following keys

NSLocationAlwaysAndWhenInUseUsageDescription
Privacy - Location When In Use Usage Description

Step 5: Initialize SDK
Make sure to initialize the SDK only one time. You can initialize SDK by "import TookanTracker" to your file.

// Set Delegate TookanTracker.shared.delegate = self

// Google API hit for ETA(In second)
TookanTracker.shared.delayTimer = 60.0 ("By passing Double value into it.")

//Google MAP key for intitialize google map.
TookanTracker.shared.googleMapKey = "YOUR_GOOGLE_MAP_API_KEY"
 Note:-
if you don't want to use google api hit for ETA and path, then use trackerOptions.setPathUpdateTimer(-1)
By default path update timer is 1 minute.

// Setting up the SDK
TookanTracker.shared.createSession(userID: "Provide Tookan Dashboard User ID",isUINeeded: false, navigationController: self.navigationController!)  

// Below code is used to create session.
TookanTracker.shared.startTarckingByJob(sharedSecertId: "tookan-sdk-345#!@", jobId: "Provide Tookan Dashboard JOB ID", userId: "Provide Tookan Dashboard User ID")
