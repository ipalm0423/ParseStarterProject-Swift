//
//  InterfaceController.swift
//  Sesame Extension
//
//  Created by 陳冠宇 on 2016/1/16.
//  Copyright © 2016年 Parse. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity



class InterfaceController: WKInterfaceController, WCSessionDelegate {

    
    @IBOutlet var statusLabel: WKInterfaceLabel!
    
    @IBOutlet var lockSwitch: WKInterfaceSwitch!
    
    var isLock = true
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.setupWCConnection()
        self.checkWCConnectReachable()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    //WC connection
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
            self.statusLabel.setText("Connect")
            
            return true
        }else {
            self.statusLabel.setText("Disconnect")
            return false
        }
    }
    
    //Watch Connect function
    //receive
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        print("rececie message")
        if let cmd = message["cmd"] as? String {
            print("got message")
            switch cmd {
            case "unlock" :
                print("cmd from iphone: unlock")
                //replyHandler(["cmdResponse" : true])
                
                //stop testing
                //let file = session.outstandingUserInfoTransfers.count
                //print("file is wait transfer: \(file)")
                //segue with data
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.lockSwitch.setOn(false)
                    self.lockSwitch.setTitle("unLock")
                    self.statusLabel.setText("unlock")
                    self.isLock = false
                })
                
                
            case "lock" :
                print("cmd from iphone: lock")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.lockSwitch.setOn(true)
                    self.lockSwitch.setTitle("Lock")
                    self.statusLabel.setText("lock")
                    self.isLock = true
                })
                //replyHandler(["cmdResponse" : true])
                
            
            case "switch" :
                print("cmd from iphone: switch")
                if self.isLock {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.lockSwitch.setOn(false)
                        self.lockSwitch.setTitle("unLock")
                        self.statusLabel.setText("unlock")
                        self.isLock = false
                    })
                }else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.lockSwitch.setOn(true)
                        self.lockSwitch.setTitle("Lock")
                        self.statusLabel.setText("lock")
                        self.isLock = true
                    })
                }
                
            default :
                print("unknow cmd from iphone")
            }
        }
    }
    
    
    func sendCMDStopPhone() {
        if self.session!.reachable {
            print("send cmd to iphone: stop")
            self.session?.sendMessage(["cmd" : "stop"], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
    }
    
    func sendCMDStartPhone() {
        if self.session!.reachable {
            print("send cmd to iphone: start")
            self.session?.sendMessage(["cmd" : "start"], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
    }
    
    func sendDataFile(array : [NSDate : Double]) {
        print("send data to iOS device")
        let applicationData = ["heartRateData" : array]
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.session?.transferUserInfo(applicationData)
        }
    }
    
    func sessionReachabilityDidChange(session: WCSession) {
        if session.reachable {
            self.statusLabel.setText("Connect")
        }else {
            self.statusLabel.setText("Disconnect")
        }
    }
    
    
    
    
}
