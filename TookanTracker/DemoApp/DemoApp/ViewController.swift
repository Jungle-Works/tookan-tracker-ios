//
//  ViewController.swift
//  TookanTracker-Demo
//
//  Created by CL-Macmini-110 on 11/20/17.
//  Copyright © 2017 CL-Macmini-110. All rights reserved.
//

import UIKit
import TookanTracker
import CoreLocation

let apiKey = "546b6480f1075f02431774714310214114e7ccf22ad87d3b581d"

struct USER_DEFAULT {
    static let isSessionExpire = "isSessionExpire"
    static let applicationMode = "ApplicationMode"
    static let isHitInProgress = "isHitInProgress"
    static let isLocationTrackingRunning = "isLocationTrackingRunning"
    static let deviceToken = "DeviceToken"
    static let sessionId = "sessionID"
    static let updatingLocationPathArray = "updatingPathLocationArray"
    static let subscribeLocation = "subscribeLocation"
    static let requestID = "requestID"
    static let sessionURL = "sessionUrl"
    static let userId = "userId"
}



class ViewController: UIViewController, TookanTrackerDelegate {

    var getLocationTimer:Timer!
    let SCREEN_SIZE = UIScreen.main.bounds
    var sessionId = ""
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var signup: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if navigationController != nil {
            if UserDefaults.standard.bool(forKey: USER_DEFAULT.isSessionExpire) == false {
                if let id = UserDefaults.standard.value(forKey: USER_DEFAULT.userId) as? String {
                    UserDefaults.standard.set(false, forKey: USER_DEFAULT.isSessionExpire)
                    
                    TookanTracker.shared.delegate = self
                    TookanTracker.shared.createSession(userID:id, apiKey: apiKey, isUINeeded: false, navigationController:self.navigationController!)
                    
                }
                
            }
        }
        
        self.setTopLabel()
        self.setTextField()
        self.setSignInButton()
        self.setSignUpButton()
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    internal func getCurrentCoordinates(_ location: CLLocation) {
        print("INAPP COORDINATES \(location)")
    }
    
    internal func logout() {
        UserDefaults.standard.set(true, forKey: USER_DEFAULT.isSessionExpire)
    }
    
    func setTextField() {
        self.emailTextField.placeholder = "Email"
        self.passwordTextField.placeholder = "Enter Job Id"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    func setSignInButton() {
        self.signInButton.layer.cornerRadius = 25.0
        self.signInButton.setTitle("Start Tarcking", for: .normal)
        self.signInButton.backgroundColor = UIColor(red: 70/255, green: 149/255, blue: 246/255, alpha: 1.0)
        self.signInButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func setSignUpButton() {
        self.signup.layer.cornerRadius = 25.0
        self.signup.setTitle("Start Tracking For Agent", for: .normal)
        self.signup.backgroundColor = UIColor.white
        self.signup.setTitleColor(UIColor(red: 70/255, green: 149/255, blue: 246/255, alpha: 1.0), for: .normal)
    }
    
    func setTopLabel() {
        self.topLabel.text = "Sign in to your account!"
        self.topLabel.font = UIFont.systemFont(ofSize: 20)
    }
    
    @IBAction func signInAction(_ sender: Any) {
        
        var param:[String:Any] = ["shared_secret": "tookan-sdk-345#!@"]
        param["job_id"] = "436463"
        param["user_id"] = "27278"
        param["request_type"] = "1"
        param["fleet_tracking"] = "1"
        
        print(param)
        Networking.sharedInstance.commonServerCall(apiName: "create_sdk_tracking_session", params: param as [String : AnyObject]?, httpMethod: HTTP_METHOD.POST) { (isSucceeded, response) in
            DispatchQueue.main.async {
                print(response)
                if isSucceeded == true {
                    if let status = response["status"] as? Int {
                        switch status {
                        case STATUS_CODES.SHOW_DATA:
                            UserDefaults.standard.set(false, forKey: USER_DEFAULT.isSessionExpire)
                            UserDefaults.standard.set("\(self.emailTextField.text ?? "")", forKey: USER_DEFAULT.userId)
                            TookanTracker.shared.delegate = self
                            TookanTracker.shared.createSession(userID:"\(self.emailTextField.text ?? "")", apiKey: apiKey, isUINeeded: false, navigationController:self.navigationController!)
                            break
                        case STATUS_CODES.INVALID_ACCESS_TOKEN:
                            UIAlertView(title: "", message: response["message"] as! String, delegate: nil, cancelButtonTitle: "OK").show()
                            break
                        default:
                            UIAlertView(title: "", message: response["message"] as! String, delegate: nil, cancelButtonTitle: "OK").show()
                            break
                        }
                    }
                } else {
                    UIAlertView(title: "", message: response["message"] as! String, delegate: nil, cancelButtonTitle: "OK").show()
                    print(response["message"] as? String ?? "somthingWrong")
                }
            }
        }
        
        
        
    }
    
    
    @IBAction func signupAction(_ sender: Any) {
        TookanTracker.shared.delegate = self
        var param:[String:Any] = ["shared_secret": "tookan-sdk-345#!@"]
        param["fleet_id"] = "33857" //"\(self.passwordTextField.text ?? "")"
        param["user_id"] = "27278"
        param["request_type"] = "1"

        print(param)
        Networking.sharedInstance.commonServerCall(apiName: "sdk_track_agent", params: param as [String : AnyObject]?, httpMethod: HTTP_METHOD.POST) { (isSucceeded, response) in
                    DispatchQueue.main.async {
                        print(response)
                        if isSucceeded == true {
                            if let status = response["status"] as? Int {
                                switch status {
                                case STATUS_CODES.SHOW_DATA:
                                    UserDefaults.standard.set(false, forKey: USER_DEFAULT.isSessionExpire)
                                    UserDefaults.standard.set("\(self.emailTextField.text ?? "")", forKey: USER_DEFAULT.userId)
                                    TookanTracker.shared.delegate = self
                                    TookanTracker.shared.createSession(userID:"27278", apiKey: apiKey, isUINeeded: false, navigationController:self.navigationController!)
                                    break
                                case STATUS_CODES.INVALID_ACCESS_TOKEN:
                                    UIAlertView(title: "", message: response["message"] as! String, delegate: nil, cancelButtonTitle: "OK").show()
                                    break
                                default:
                                    UIAlertView(title: "", message: response["message"] as! String, delegate: nil, cancelButtonTitle: "OK").show()
                                    break
                                }
                            }
                        } else {
                            UIAlertView(title: "", message: response["message"] as! String, delegate: nil, cancelButtonTitle: "OK").show()
                            print(response["message"] as? String ?? "somthingWrong")
                        }
                    }
                }
        
    }
    
    @IBAction func stopTracking(_ sender: Any) {
        
        TookanTracker.shared.stopTracking(sessionID: self.sessionId)
    }
    
    
    func getAspectRatioValue(value:CGFloat) -> CGFloat {
        return (value / 375) * SCREEN_SIZE.width
    }
   
    func loginAction() {
        //        let response = loc.startLocationService()
        //        if(response.0 == true) {
        //            self.resetLocationTimer()
        //            getLocationTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.startSession), userInfo: nil, repeats: true)
        //        } else {
        //            print(response.1)
        //            UIAlertView(title: "", message: response.1, delegate: self, cancelButtonTitle: "OK").show()
        //        }
    }
    
    //MARK: RESET LOCATION TIMER
    func resetLocationTimer() {
        if getLocationTimer != nil {
            getLocationTimer.invalidate()
            getLocationTimer = nil
        }
    }
    
    //MARK: START SESSION
    //    @objc func startSession() {
    //        let location = loc.getCurrentLocation()
    //        if  location != nil && location?.coordinate.latitude != 0.0 {
    //            self.resetLocationTimer()
    ////            self.startSessionHit(sessionId: "", location: location!,requestId: "")
    //        }
    //    }
    
    
    func getSessionId(sessionId: String) {
        print("Sessionid: \(sessionId)")
        self.sessionId = sessionId
    }
}

