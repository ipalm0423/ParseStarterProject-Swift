/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import WatchConnectivity
import Parse

// If you want to use any of the UI components, uncomment this line
// import ParseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()

        // ****************************************************************************
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId("rpzQFmI1Tqh2nmjQTEhrPzTHpzoRF7bxFOtM2drd",
            clientKey: "XsXSIAmEmCpq1uuU88OScF599CN57X6AEYmGCCAf")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************

        PFUser.enableAutomaticUser()

        let defaultACL = PFACL();

        // If you would like all objects to be private by default, remove this line.
        defaultACL.publicReadAccess = true

        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)

        if application.applicationState == UIApplicationState.Background {
            print("app is in background")
            self.setupWCConnection()
            self.checkWCConnectReachable()
            self.sendCMDSwitchPhone()
            if let options = launchOptions {
                //test switch
                print("have option")
                
                //wait modify
                if let payload = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
                    print("payload has value")
                    let isLock = payload["p"] as? String
                    let targetObject = PFObject(withoutDataWithClassName: "Photo", objectId: isLock)
                    targetObject.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                        print("error: \(error)")
                        //.......do something
                    })
                }
                
            }
        }
        
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.

            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
                
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
            

            
        }

        //
        //  Swift 1.2
        //
        //        if application.respondsToSelector("registerUserNotificationSettings:") {
        //            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        //            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        //            application.registerUserNotificationSettings(settings)
        //            application.registerForRemoteNotifications()
        //        } else {
        //            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
        //            application.registerForRemoteNotificationTypes(types)
        //        }

        //
        //  Swift 2.0
        //
                if #available(iOS 8.0, *) {
                    let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
                    let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
                    application.registerUserNotificationSettings(settings)
                    application.registerForRemoteNotifications()
                } else {
                    let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
                    application.registerForRemoteNotificationTypes(types)
                }

        return true
    }

    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    func setupWCConnection() {
        if let session = self.session {
            self.session?.delegate = self
            self.session?.activateSession()
            print("active session")
        }
    }
    
    func checkWCConnectReachable() -> Bool {
        
        if let session = session where session.reachable {
            //self.connectionLabel.text = "Connect"
            
            return true
        }else {
            //self.connectionLabel.text = "Disconnect"
            return false
        }
    }
    
    func sendCMDSwitchPhone() {
        if self.session!.reachable {
            print("send cmd to iphone: switch")
            self.session?.sendMessage(["cmd" : "switch"], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
    }
    
    func sendCMDLockPhone() {
        if self.session!.reachable {
            print("send cmd to iphone: lock")
            self.session?.sendMessage(["cmd" : "lock"], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
    }
    
    func sendCMDUnLockPhone() {
        if self.session!.reachable {
            print("send cmd to iphone: unlock")
            self.session?.sendMessage(["cmd" : "unlock"], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
    }
    
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()

        PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n");
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error)
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("did recieve APNS: content")
        print("userinfo: \(userInfo)")
        let VC = ViewController()
        self.setupWCConnection()
        self.checkWCConnectReachable()
        if let isLock = userInfo["lock"] as? String {
            if isLock == "true" {
                self.sendCMDLockPhone()
            }else if isLock == "false" {
                self.sendCMDUnLockPhone()
            }
        }
        
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        print("did recieve APNS")
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            self.setupWCConnection()
            self.checkWCConnectReachable()
            self.sendCMDSwitchPhone()
        }
    }

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }

    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
}
