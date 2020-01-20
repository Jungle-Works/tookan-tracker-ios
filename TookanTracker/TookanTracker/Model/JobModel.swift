//
//  JobModel.swift
//  TookanTracker
//
//  Created by Mukul Kansal on 17/01/20.
//  Copyright © 2020 CL-Macmini-110. All rights reserved.
//

import Foundation

class JobModel :NSObject{
    var jobData = [String: Any]()
    var jobLat = ""
    var joblng = ""
    var sessionId = ""
    var sessionUrl = ""
    
    
    init(json:[String:Any]) {
          
          super.init()
          print(json)
          
        if let value = json["jobs_data"] as? [String:Any]{
            self.jobData = value
        }
        
          if let value = json["latitude"] as? String{
              self.jobLat = value
          }
          
          if let value = json["longitude"] as? String{
              self.joblng = value
          }
          
          if let value = json["session_id"] as? String{
              self.sessionId = value
          }
          
          if let value = json["session_url"] as? String{
              self.sessionUrl = value
          }
      }
      
      func getDuplicateInstance() -> AgentDetailModel {
          let task = AgentDetailModel(json: [String : Any]())
          task.jobLatitude = self.jobLat
          task.jobLongitude = self.joblng
          task.sessionId = self.sessionId
          task.sessionUrl = self.sessionUrl
        return task
      }
//
//        "jobs_data" =     {
//            jobs =         (
//                            {
//                    "brand_image" = "";
//                    "call_fleet_as" = Worker;
//                    "company_image" = "https://tookan.s3.amazonaws.com/company_images/F9ZV1553079455023-123.png";
//                    "company_name" = Foodmania;
//                    "completed_datetime" = "0000-00-00 00:00:00";
//                    "customer_username" = "";
//                    "fav_icon" = "<null>";
//                    "fleet_id" = 33857;
//                    "fleet_image" = "https://tookan.s3.amazonaws.com/company_images/F9ZV1553079455023-123.png";
//                    "fleet_latitude" = "30.6951903";
//                    "fleet_longitude" = "76.8793783";
//                    "fleet_name" = "ajay ww";
//                    "fleet_phone" = "+9197465341313";
//                    "fleet_status" = 0;
//                    "fleet_thumb_image" = "https://tookan.s3.amazonaws.com/fleet_thumb_profile/thumb-t9lr1547034223444-cnvU1547034223382TOOKAN09012019051342.jpg";
//                    "is_available" = 0;
//                    "is_company_image_view" = 1;
//                    "is_customer_rated" = 0;
//                    "is_driver_image_view" = 0;
//                    "is_whitelabel" = 0;
//                    "job_address" = "Unnamed Road, Chaunki, Panchkula, Haryana, India, 134107";
//                    "job_hash" = 8dd7ee77caeb20519798d7522a106bd2;
//                    "job_id" = 436463;
//                    "job_latitude" = "30.6951933";
//                    "job_longitude" = "76.8793952";
//                    "job_pickup_address" = "Unnamed Road, Chaunki, Panchkula, Haryana, India, 134107";
//                    "job_pickup_latitude" = "30.6951933";
//                    "job_pickup_longitude" = "76.8793952";
//                    "job_status" = 4;
//                    "job_type" = 3;
//                    logo = "<null>";
//                    "map_theme" = 1;
//                    "partner_order_id" = "<null>";
//                    "pickup_delivery_relationship" = 43646315761311661001385;
//                    "started_datetime" = "2019-12-12T06:12:53.000Z";
//                    status = 0;
//                    "tracking_language" = da;
//                    "transport_type" = 2;
//                    "user_id" = 27278;
//                }
//            );
//            "routed_jobs" =         (
//            );
//            setup =         {
//                "c_masking" = 0;
//                "disable_rating" = 0;
//                "fugu_chat" = 1;
//                "fugu_chat_in_customer_app" = 1;
//                "is_customer_rated" = 0;
//                "is_redirect_tracking_link" = 1;
//                "map_config" =             {
//                    googleMap =                 {
//                        "api_key" = "AIzaSyAdWwy8VFj2_KIoTCnk8AyO7Zi0tKuNCaU";
//                        "tracking_link_api_key" = "AIzaSyAdWwy8VFj2_KIoTCnk8AyO7Zi0tKuNCaU";
//                    };
//                    hereMap =                 {
//                        "app_code" = YzC75hij7ei6sJafAFAsjg;
//                        "app_id" = G29ds3TBCWxlbcVgAQXh;
//                    };
//                    jungleMap =                 {
//                        radius = 150;
//                    };
//                    mapBox =                 {
//                        "access_token" = "pk.eyJ1IjoiZHVyZ2VzaGthc2h5YXAiLCJhIjoiY2p5emNiZHNvMDA4eTNjbnFscXkzaXplOCJ9.ue2jR5rnbDRTWTSVKapzZQ";
//                    };
//                    setMap = 1;
//                    type = 0;
//                };
//                "map_overlays" = 0;
//                "single_tracking" = 0;
//                status = 0;
//                "tracking_link" =             {
//                    "no_agent_tracking_text" = "";
//                    "show_eta_intermediate_stops" = 1;
//                    "waiting_time_at_the_stop" = 12gyyy;
//                };
//            };
//        };
//        latitude = "30.6951903";
//        longitude = "76.8793783";
//        "session_id" = d8d35af62bca6a63bf921d296c284833;
//        "session_url" = "https://tracking.tookan.io/?session_id=d8d35af62bca6a63bf921d296c284833";
//    }, "status": 200, "message": Successful]
}
