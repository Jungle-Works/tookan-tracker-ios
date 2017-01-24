//
//  MqttClass.swift
//  Tookan
//
//  Created by cl-macmini-45 on 11/07/16.
//  Copyright © 2016 Click Labs. All rights reserved.
//

import UIKit
import CocoaMQTT

open class MqttClass: NSObject {
    
    static let sharedInstance = MqttClass()
    var mqtt: CocoaMQTT?
    var didConnectAck = false
    var hostAddress = "tracking.tookan.io"//"test.tookanapp.com"
    var portNumber:UInt16 = 1883
    var accessToken = ""
    var key = ""
    
    func connectToServer() {
        mqtt!.connect()
    }
    
    func mqttSetting() {
        let clientIdPid = "CocoaMQTT--" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientId: clientIdPid, host: hostAddress, port:portNumber)
        //mqtts
        if let mqtt = mqtt {
            mqtt.username = "t"
            mqtt.password = "t"
            mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
            mqtt.keepAlive = 90
            mqtt.delegate = self
        }
    }
    
    func sendLocation(_ location:String) {
        if IJReachability.isConnectedToNetwork() == true {
            if(didConnectAck == true) {
                UserDefaults.standard.set(true, forKey: USER_DEFAULT.isHitInProgress)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                let sendData = ["access_token":accessToken,
                                "key":key,
                                "location":"\(location)"]
                print("Send Data = \(sendData)")
                let sendDataArray = NSMutableArray()
                sendDataArray.add(sendData)
                mqtt!.publish("UpdateLocation", withString:sendDataArray.jsonString , qos: .qos1)
            } else {
                if(mqtt?.connState == CocoaMQTTConnState.disconnected) {
                    self.mqttSetting()
                    self.connectToServer()
                }
            }
        }
    }
    
    func stopLocation() {
        let sendData = ["access_token":accessToken,
                        "key":key]
        let sendDataArray = NSMutableArray()
        sendDataArray.add(sendData)
        mqtt!.publish("StopTracking", withString:sendDataArray.jsonString , qos: .qos1)
    }
    
    func disconnect() {
        mqtt!.disconnect()
    }
    
}

extension MqttClass: CocoaMQTTDelegate {
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            mqtt.subscribe(self.accessToken, qos: CocoaMQTTQOS.qos1)
            mqtt.ping()
            didConnectAck = true
            //mqtt.publish("UpdateLocation", withString:"Hello" , qos: .QOS1)
        }
        
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string)")
        var locationArray = NSMutableArray()
        if let array = UserDefaults.standard.object(forKey: USER_DEFAULT.locationArray) as? NSMutableArray {
            locationArray = NSMutableArray(array: array)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        var sentLocationArray = NSMutableArray()
        if let sentJsonString = message.string {
            let locationObject = sentJsonString.jsonObject
            let locationObjectArray = locationObject.object(at: 0) as! NSDictionary
            let locationString = locationObjectArray["location"] as! String
            sentLocationArray = NSMutableArray(array: locationString.jsonObject)
        }
        for i in (0..<sentLocationArray.count) {
            let sendDictionaryObject = sentLocationArray.object(at: i) as! NSDictionary
            if let sendTimeStamp = sendDictionaryObject["tm_stmp"] as? String {
                for j in (0..<locationArray.count) {
                    let locationDictionaryObject = locationArray.object(at: j) as! NSDictionary
                    if let locationTimeStamp = locationDictionaryObject["tm_stmp"] as? String {
                        if(sendTimeStamp == locationTimeStamp) {
                            locationArray.removeObject(at: j)
                            break
                        }
                    }
                }
            }
        }
        UserDefaults.standard.set(locationArray, forKey: USER_DEFAULT.locationArray)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(false, forKey: USER_DEFAULT.isHitInProgress)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
        UserDefaults.standard.set(false, forKey: USER_DEFAULT.isHitInProgress)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceivedMessage: \(message.string) with id \(id)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: NSError?) {
        didConnectAck = false
        _console("mqttDidDisconnect")
        UserDefaults.standard.set(false, forKey: USER_DEFAULT.isHitInProgress)
    }
    
    func _console(_ info: String) {
        print("Delegate: \(info)")
    }
}
