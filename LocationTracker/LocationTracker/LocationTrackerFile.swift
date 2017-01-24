

//
//  LocationHandler.swift
//  Tookan
//
//  Created by Click Labs on 8/13/15.
//  Copyright (c) 2015 Click Labs. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import SystemConfiguration

@objc public protocol LocationTrackerDelegate {
    @objc optional func currentLocation(_ location:CLLocation)
}


public enum LocationFrequency: Int {
    case low = 0
    case medium
    case high
}

open class LocationTrackerFile:NSObject, CLLocationManagerDelegate {
    
    open var delegate:LocationTrackerDelegate!
    fileprivate var host = "tracking.tookan.io"
    fileprivate var portNumber:UInt16 = 1883
    fileprivate var slotTime = 5.0
    fileprivate var maxSpeed:Float = 30.0
    fileprivate var maxAccuracy = 20.0
    fileprivate var maxDistance = 20.0
    open var locationFrequencyMode = LocationFrequency.high
    open var accessToken:String = ""
    open var uniqueKey:String = ""
    
    fileprivate static let locationManagerObj = CLLocationManager()
    fileprivate static let locationTracker = LocationTrackerFile()
    
    fileprivate var myLastLocation: CLLocation!
    fileprivate var myLocation: CLLocation!
    fileprivate var myLocationAccuracy: CLLocationAccuracy!
    fileprivate var locationUpdateTimer: Timer!
    fileprivate var locationManager:CLLocationManager!
    fileprivate var speed:Float = 0
    fileprivate var bgTask: BackgroundTaskManager?
    
    let SDKVersion = "1.0"
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTrackerFile.applicationEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTrackerFile.appEnterInTerminateState), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTrackerFile.enterInForegroundFromBackground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTrackerFile.becomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        UserDefaults.standard.set(false, forKey: USER_DEFAULT.isHitInProgress)
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    
    open class func sharedInstance() -> LocationTrackerFile {
        return locationTracker
    }
    
    open class func sharedLocationManager() -> CLLocationManager {
        return locationManagerObj
    }
    
    func applicationEnterBackground() {
        self.setLocationUpdate()
        self.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager()
        self.bgTask!.beginNewBackgroundTask()
        UserDefaults.standard.setValue("Background", forKey: USER_DEFAULT.applicationMode)
        self.updateLocationToServer()
        if(self.locationUpdateTimer != nil) {
            self.locationUpdateTimer.invalidate()
            self.locationUpdateTimer = nil
        }
        self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: slotTime, target: self, selector: #selector(LocationTrackerFile.updateLocationToServer), userInfo: nil, repeats: true)
    }
    
    func enterInForegroundFromBackground(){
        UserDefaults.standard.setValue("Foreground", forKey: USER_DEFAULT.applicationMode)
        self.updateLocationToServer()
        if(self.locationUpdateTimer != nil) {
            self.locationUpdateTimer.invalidate()
            self.locationUpdateTimer = nil
        }
        self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: self.slotTime, target: self, selector: #selector(LocationTrackerFile.updateLocationToServer), userInfo: nil, repeats: true)
    }
    
    func appEnterInTerminateState() {
        UserDefaults.standard.setValue("Terminate", forKey: USER_DEFAULT.applicationMode)
        if(self.locationManager != nil) {
            self.locationManager.stopUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func becomeActive() {
        if(self.locationManager == nil) {
            self.restartLocationUpdates()
        }
    }

    open func getCurrentLocation() -> CLLocation {
        if(self.myLocation == nil) {
            return CLLocation()
        }
        return self.myLocation
    }
    
    fileprivate func setLocationUpdate() {
        if(UserDefaults.standard.bool(forKey: USER_DEFAULT.isLocationTrackingRunning) == true) {
            MqttClass.sharedInstance.mqttSetting()
            MqttClass.sharedInstance.connectToServer()
            if(self.locationManager != nil) {
                self.locationManager.stopMonitoringSignificantLocationChanges()
            }
            locationManager = LocationTrackerFile.sharedLocationManager()
            self.setFrequency()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.activityType = CLActivityType.automotiveNavigation
            locationManager.pausesLocationUpdatesAutomatically = false
            if(maxDistance == 0) {
                locationManager.distanceFilter = kCLDistanceFilterNone
            } else {
                locationManager.distanceFilter = maxDistance
            }
        
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    
     fileprivate func setFrequency() {
        switch locationFrequencyMode {
        case LocationFrequency.low:
            slotTime = 60.0
            maxDistance = 100.0
            break
        case LocationFrequency.medium:
            slotTime = 30.0
            maxDistance = 50.0
            break
        case LocationFrequency.high:
            slotTime = 5.0
            maxDistance = 20.0
            break
        }
    }
    
    fileprivate func restartLocationUpdates() {
        if(self.locationUpdateTimer != nil) {
            self.locationUpdateTimer.invalidate()
            self.locationUpdateTimer = nil
        }
        if(self.locationManager != nil) {
            self.locationManager.stopMonitoringSignificantLocationChanges()
        }
                
        setLocationUpdate()
        self.updateLocationToServer()
        self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: slotTime, target: self, selector: #selector(LocationTrackerFile.updateLocationToServer), userInfo: nil, repeats: true)
    }
    
    open func startLocationTracking() -> (Bool, String) {
        let response = self.isAllPermissionAuthorized()
        if(response.0 == true) {
            UserDefaults.standard.set(true, forKey: USER_DEFAULT.isLocationTrackingRunning)
            setLocationUpdate()
            if(self.locationUpdateTimer != nil) {
                self.locationUpdateTimer?.invalidate()
                self.locationUpdateTimer = nil
            }
            self.updateLocationToServer()
            self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: self.slotTime, target: self, selector: #selector(LocationTrackerFile.updateLocationToServer), userInfo: nil, repeats: true)
        }
        return response
    }
    
    open func stopLocationTracking() {
        if(self.locationUpdateTimer != nil) {
            self.locationUpdateTimer.invalidate()
            self.locationUpdateTimer = nil
        }
        let locationManager: CLLocationManager = LocationTrackerFile.sharedLocationManager()
        locationManager.stopUpdatingLocation()
        
       // MqttClass.sharedInstance.stopLocation()
        UserDefaults.standard.set(false, forKey: USER_DEFAULT.isLocationTrackingRunning)
        MqttClass.sharedInstance.disconnect()
        
    }
    
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager()
        self.bgTask!.beginNewBackgroundTask()
        if locations.last != nil {
            self.myLocation = locations.last! as CLLocation
            self.myLocationAccuracy = self.myLocation.horizontalAccuracy
            self.applyFilterOnGetLocation()
            if(UserDefaults.standard.bool(forKey: USER_DEFAULT.isLocationTrackingRunning) == true) {
                delegate.currentLocation!(self.myLocation)
            }
        }
    }
    
    fileprivate func applyFilterOnGetLocation() {
        if self.myLocation != nil  {
            var locationArray = NSMutableArray()
            if let array = UserDefaults.standard.object(forKey: USER_DEFAULT.locationArray) as? NSMutableArray {
                locationArray = NSMutableArray(array: array)
            }
            if UserDefaults.standard.bool(forKey: USER_DEFAULT.isLocationTrackingRunning) == true {
                if(self.myLocationAccuracy < maxAccuracy){
                    if(self.myLastLocation == nil) {
                        var myLocationToSend = NSMutableDictionary()
                        let timestamp = String().getUTCDateString
                        myLocationToSend = ["lat" : myLocation!.coordinate.latitude as Double,"lng" :myLocation!.coordinate.longitude as Double, "tm_stmp" : timestamp, "bat_lvl" : UIDevice.current.batteryLevel * 100, "acc":(self.myLocationAccuracy != nil ? self.myLocationAccuracy! : 300)]
                        self.addFilteredLocationToLocationArray(myLocationToSend)
                        self.myLastLocation = self.myLocation
                    } else {
                        if(self.getSpeed() < maxSpeed) {
                            var myLocationToSend = NSMutableDictionary()
                            let timestamp = String().getUTCDateString
                            myLocationToSend = ["lat" : myLocation!.coordinate.latitude as Double,"lng" :myLocation!.coordinate.longitude as Double, "tm_stmp" : timestamp, "bat_lvl" : UIDevice.current.batteryLevel * 100, "acc":(self.myLocationAccuracy != nil ? self.myLocationAccuracy! : 300)]
                            self.addFilteredLocationToLocationArray(myLocationToSend)
                            self.myLastLocation = self.myLocation
                        }
                    }
                }
            }
            
          //  if(NSUserDefaults.standardUserDefaults().valueForKey(USER_DEFAULT.applicationMode) != nil && (NSUserDefaults.standardUserDefaults().valueForKey(USER_DEFAULT.applicationMode) as! String == "Background" || NSUserDefaults.standardUserDefaults().valueForKey(USER_DEFAULT.applicationMode) as! String == "Terminate")) {
                if(UserDefaults.standard.bool(forKey: USER_DEFAULT.isHitInProgress) == false) {
                    if locationArray.count >= 5 {
                        let locationString = locationArray.jsonString
                        sendRequestToServer(locationString)
                    }
                }
            //}
        }
    }
    
    fileprivate func addFilteredLocationToLocationArray(_ myLocationToSend:NSMutableDictionary) {
        if(UserDefaults.standard.bool(forKey: USER_DEFAULT.isLocationTrackingRunning) == true){
            var locationArray = NSMutableArray()
            if let array = UserDefaults.standard.object(forKey: USER_DEFAULT.locationArray) as? NSMutableArray {
                locationArray = NSMutableArray(array: array)
            }
            if(locationArray.count >= 1000) {
                locationArray.removeObject(at: 0)
            }
            locationArray.add(myLocationToSend)
            UserDefaults.standard.set(locationArray, forKey: USER_DEFAULT.locationArray)
        }
    }
    
    
     func updateLocationToServer() {
        var locationArray = NSMutableArray()
        if let array = UserDefaults.standard.object(forKey: USER_DEFAULT.locationArray) as? NSMutableArray {
            locationArray = NSMutableArray(array: array)
        }
        if IJReachability.isConnectedToNetwork(){
            if(UserDefaults.standard.bool(forKey: USER_DEFAULT.isHitInProgress) == false) {
                if locationArray.count > 0 {
                    let locationString = locationArray.jsonString
                    sendRequestToServer(locationString)
                }
            }
        }
    }
    
    fileprivate func sendRequestToServer(_ locationString:String) {
        if(UserDefaults.standard.bool(forKey: USER_DEFAULT.isLocationTrackingRunning) == true) {
            MqttClass.sharedInstance.hostAddress = self.host
            MqttClass.sharedInstance.portNumber = self.portNumber
            MqttClass.sharedInstance.accessToken = self.accessToken
            MqttClass.sharedInstance.key = self.uniqueKey
            MqttClass.sharedInstance.sendLocation(locationString)//MQTT
        }
    }
    
    fileprivate func updateLastSavedLocationOnServer() {
        if(UserDefaults.standard.bool(forKey: USER_DEFAULT.isLocationTrackingRunning) == true) {
            var locationArray = NSMutableArray()
            if let array = UserDefaults.standard.object(forKey: USER_DEFAULT.locationArray) as? NSMutableArray {
                locationArray = NSMutableArray(array: array)
            }
            self.setLocationUpdate()
            if(UserDefaults.standard.bool(forKey: USER_DEFAULT.isHitInProgress) == false) {
                if(locationArray.count > 0) {
                    sendRequestToServer(locationArray.jsonString)
                } else {
                    var myLocationToSend = NSMutableDictionary()
                    myLocationToSend = ["bat_lvl" : UIDevice.current.batteryLevel * 100]
                    let highLocationArray = NSMutableArray()
                    highLocationArray.add(myLocationToSend)
                    let locationString = highLocationArray.jsonString
                    sendRequestToServer(locationString)
                }
            }
        }
    }
    
    fileprivate func getSpeed() -> Float {
        if(myLastLocation != nil) {
            let time = self.myLocation.timestamp.timeIntervalSince(myLastLocation.timestamp)
            let distance:CLLocationDistance = myLocation.distance(from: myLastLocation)
            if(distance > 200) {
                self.locationManager.stopUpdatingLocation()
                if let json = NetworkingHelper.sharedInstance.getLatLongFromDirectionAPI("\(myLastLocation.coordinate.latitude),\(myLastLocation.coordinate.longitude)", destination: "\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)") {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let routes = json["routes"] {
                        if(routes.count > 0) {
                            if let legs = routes[0]["legs"]!{
                                if(legs.count > 0) {
                                    if let _ = legs[0]["distance"]!!["value"] as? Int {
                                        //                                if(distance < 200) {
                                        if let polyline = routes[0]["overview_polyline"]!!["points"] as? String {
                                            let locations = NetworkingHelper.sharedInstance.decodePolylineForCoordinates(polyline)
                                            for i in (0..<locations.count) {
                                                var myLocationToSend = NSMutableDictionary()
                                                let timestamp = String().getUTCDateString
                                                myLocationToSend = ["lat" : locations[i].coordinate.latitude as Double,"lng" :locations[i].coordinate.longitude as Double, "tm_stmp" : timestamp, "bat_lvl" : UIDevice.current.batteryLevel * 100,"acc":(self.myLocationAccuracy != nil ? self.myLocationAccuracy! : 300)]
                                               
                                                self.addFilteredLocationToLocationArray(myLocationToSend)
                                                self.myLastLocation = CLLocation(latitude: locations[i].coordinate.latitude, longitude: locations[i].coordinate.longitude)
                                                self.setLocationUpdate()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.setLocationUpdate()
                        speed = Float(distance) / Float(time)
                        if(speed > 0) {
                            return speed
                        }
                        return 0.0
                    }
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.setLocationUpdate()
                    speed = Float(distance) / Float(time)
                    if(speed > 0) {
                        return speed
                    }
                    return 0.0
                }
                return 0.0
            } else {
                speed = Float(distance) / Float(time)
                if(speed > 0) {
                    return speed
                }
                return 0.0
            }
        }
        return 0.0
    }
    
    fileprivate func isAllPermissionAuthorized() -> (Bool, String) {
        //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
        if(UIApplication.shared.backgroundRefreshStatus == UIBackgroundRefreshStatus.denied) {
            return (false,"The app doesn't work without the Background App Refresh enabled.")
        } else if (UIApplication.shared.backgroundRefreshStatus == UIBackgroundRefreshStatus.restricted) {
            return (false,"The app doesn't work without the Background App Refresh enabled.")
        } else {
            return self.isAppLocationEnabled()
        }
    }
    
    fileprivate func isAppLocationEnabled() -> (Bool,String) {
        if CLLocationManager.locationServicesEnabled() == false {
            return (false,"Background Location Access Disabled")
        } else {
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus == CLAuthorizationStatus.denied || authorizationStatus == CLAuthorizationStatus.restricted {
                return (false,"Background Location Access Disabled")
            } else {
                return self.isAuthorizedUser()
            }
        }
    }
    
    fileprivate func isAuthorizedUser() -> (Bool,String) {
        let params = ["u_socket_id":uniqueKey,
                      "f_socket_id":self.accessToken,
                      "sdk_version":SDKVersion,
                      "timezone":NSTimeZone.system.secondsFromGMT() / 60,
                      "frequency":"\(self.locationFrequencyMode.rawValue)",
                      "device_details":["device_type":"1",
                                        "device_name":UIDevice.current.name,
                                        "imei":"",
                                        "os":(UIDevice.current.systemVersion as NSString).doubleValue,
                                        "manufacturer":"Apple",
                                        "model":UIDevice.current.modelName,
                                        "locale": Locale.current.identifier
                                        ]] as [String : Any]
        print(params)
        let jsonResponse = NetworkingHelper.sharedInstance.getValidation("validate", params: params)
        if(jsonResponse.0 == true) {
            let json = jsonResponse.1
            if let status = json["status"] as? Int {
                if status == 200 {
                   return (true,json["message"] as! String)
                } else {
                    return (false,json["message"] as! String)
                }
            }
            return (false,"Invalid Access")
        } else {
            let json = jsonResponse.1
            return (false,json["message"] as! String)
        }
    }
}

