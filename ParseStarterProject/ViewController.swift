/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupWCConnection()
        self.checkWCConnectReachable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet var label1: UILabel!
    
    @IBOutlet var connectionLabel: UILabel!
    
    
    @IBOutlet var switch1: UISwitch!
    
    @IBOutlet var sendButton: UIButton!
    
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
            self.connectionLabel.text = "Connect"
            
            return true
        }else {
            self.connectionLabel.text = "Disconnect"
            return false
        }
    }
    
    //Watch Connect function
    //receive
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print(message)
        if let cmd = message["cmd"] as? String {
            switch cmd {
            case "unlock" :
                print("cmd from iphone: unlock")
                //replyHandler(["cmdResponse" : true])
                
                //stop testing
                //let file = session.outstandingUserInfoTransfers.count
                //print("file is wait transfer: \(file)")
                //segue with data
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.switch1.setOn(false, animated: true)
                    self.label1.text = "unLock"
                })
                
                
            case "lock" :
                print("cmd from iphone: lock")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.switch1.setOn(true, animated: true)
                    self.label1.text = "Lock"
                })
                //replyHandler(["cmdResponse" : true])
                
                
                
            default :
                print("unknow cmd from iphone")
            }
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
    
    func sendDataFile(array : [NSDate : Double]) {
        print("send data to iOS device")
        let applicationData = ["heartRateData" : array]
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.session?.transferUserInfo(applicationData)
        }
    }
    
    var lockIsLock = true
    
    @IBAction func sendButtonTouch(sender: AnyObject) {
        print("send button touch")
        if lockIsLock {
            self.lockIsLock = false
            self.label1.text = "unLock"
            self.switch1.setOn(false, animated: true)
            self.sendCMDUnLockPhone()
            
        }else {
            self.lockIsLock = true
            self.switch1.setOn(true, animated: true)
            self.label1.text = "Lock"
            self.sendCMDLockPhone()
        }
    }
    
    
}
