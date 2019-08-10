//
//  FirstViewController.swift
//  tabbedApp
//
//  Created by James rymer on 6/24/19.
//  Copyright © 2019 James rymer. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import CommonCrypto

class FirstViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var homeAddr: UITextField!
    @IBOutlet weak var desAddr1: UITextField!
    @IBOutlet var desAddr2: UITextField!
    @IBOutlet var desAddr3: UITextField!
    @IBOutlet var desAddr4: UITextField!
    @IBOutlet var desAddr5: UITextField!
    @IBOutlet var submit: UIButton!
    @IBOutlet var mirrorID: UITextField!
    @IBOutlet var mirrorPin: UITextField!
    @IBOutlet var saveMirror: UIButton!
    @IBOutlet var timeFormatSwitch: UISwitch!
    @IBOutlet var tempSwitch: UISwitch!
    
    // Sets up the view on load
    override func viewDidLoad() {
        super.viewDidLoad()
        homeAddr.delegate = self
        desAddr1.delegate = self
        desAddr2.delegate = self
        desAddr3.delegate = self
        desAddr4.delegate = self
        desAddr5.delegate = self
        mirrorID.delegate = self
        mirrorPin.delegate = self
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        readSavedData()
        pullMirrorData()
    }
    

    // Dismisses keyboard when the return key is tapped
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // Dismisses keyboard when the view is tapped
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // Takes the information in the text fields and makes a POST request to the web service
    @IBAction func buttonTapped(_ sender: UIButton) {
        let homeAddrText = self.homeAddr.text!
        let desAddr1Text = self.desAddr1.text!
        let desAddr2Text = self.desAddr2.text!
        let desAddr3Text = self.desAddr3.text!
        let desAddr4Text = self.desAddr4.text!
        let desAddr5Text = self.desAddr5.text!
        let mirrorIDText = self.mirrorID.text!
        let mirrorPinText = self.mirrorPin.text!
        var tempBool = 0
        var timeBool = 0
        
        if tempSwitch.isOn {
            tempBool = 1
        }
        if timeFormatSwitch.isOn {
            timeBool = 1
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://srm.hoy.mybluehost.me/webservice.php/")! as URL)
        request.httpMethod = "POST"
        let postString = "homeAddr=\(homeAddrText)&desAddr1=\(desAddr1Text)&desAddr2=\(desAddr2Text)&desAddr3=\(desAddr3Text)&desAddr4=\(desAddr4Text)&desAddr5=\(desAddr5Text)&time_format=\(timeBool)&temp_format=\(tempBool)&mirrorID=\(mirrorIDText)&mirrorPinHash=\(sha256(str: mirrorPinText))"
        print(sha256(str: mirrorPinText))
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error) )")
                return
            }
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            print("responseString = \(String(describing: responseString) )")
        }
        task.resume()
    }
    
   
   
    // Changes the state of timeFormatSwitch
    @IBAction func timeFormatToggled(_ sender: UISwitch) {
        timeFormatSwitch.setOn(!sender.isOn, animated: true)
    }
    
    // Changes the state of tempSwitch
    @IBAction func tempToggled(_ sender: UISwitch) {
         tempSwitch.setOn(!sender.isOn, animated: true)
    }
    
    // Makes a request to the web service for the information for the mirror with the value in mirrorID
    // Sets the values of the text fields with the requested information
    func pullMirrorData(){
        
        let mirrorIDText = self.mirrorID.text!
        let mirrorPinText = self.mirrorPin.text!
        let request = NSMutableURLRequest(url: NSURL(string: "http://srm.hoy.mybluehost.me/getMirrorSettings.php/")! as URL)
        
        request.httpMethod = "POST"
        let postString = "mirrorID=\(mirrorIDText)&mirrorPinHash=\(sha256(str: mirrorPinText))"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            print("responseString = \(String(describing: responseString) )")
            
            DispatchQueue.main.async {
                
                if error == nil {
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            self.setTextFieledValues(json: json)
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
    }
    
    // Takes a dictionary as a paramater and updates the values of the text boxes with the information in the dictionary
    func setTextFieledValues(json: [String: Any]){
        if let homeAddr = json["homeAddr"] as? String {
            self.homeAddr.text = homeAddr
        }
        if let desAddr1 = json["desAddr1"] as? String {
            self.desAddr1.text = desAddr1
        }
        if let desAddr2 = json["desAddr2"] as? String {
            self.desAddr2.text = desAddr2
        }
        if let desAddr3 = json["desAddr3"] as? String {
            self.desAddr3.text = desAddr3
        }
        if let desAddr4 = json["desAddr4"] as? String {
            self.desAddr4.text = desAddr4
        }
        if let desAddr5 = json["desAddr5"] as? String {
            self.desAddr5.text = desAddr5
        }
        if let tempBool = json["temp_format"] as? String {
            if(tempBool == "1"){
                self.tempSwitch.setOn(true, animated: true)
            } else if (tempBool == "0") {
                self.tempSwitch.setOn(false, animated: true)
            }
        }
        if let timeBool = json["time_format"] as? String {
            print("in time")
            if(timeBool == "1"){
                self.timeFormatSwitch.setOn(true, animated: true)
            } else if (timeBool == "0") {
                self.timeFormatSwitch.setOn(false, animated: true)
            }
        }
    }
    
    // Saves the data in the mirrorID and mirrorPin textfields to a file on the device to be retrieved later
    @IBAction func saveMirrorButtonTap(_ sender: UIButton) {
        
        let fileName = "mirrorSettings"
        let dir = try? FileManager.default.url(for: .documentDirectory,  in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            
            let outString = mirrorID.text! + "," + mirrorPin.text!
            do {
                try outString.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }
        pullMirrorData()
    }
    
    // Reads the mirrorID and mirrorPin from a file on the device
    func readSavedData(){
        let fileName = "mirrorSettings"
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            
            var inString = ""
            do {
                inString = try String(contentsOf: fileURL)
                let inStringSplit = inString.components(separatedBy: ",")
                self.mirrorID.text! = inStringSplit[0]
                self.mirrorPin.text! = inStringSplit[1]
            } catch {
                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            }
            
        }
        
    }
    
    /**
     * Function from https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5
     * Example SHA 256 Hash using CommonCrypto
     * CC_SHA256 API exposed from from CommonCrypto-60118.50.1:
     * https://opensource.apple.com/source/CommonCrypto/CommonCrypto-60118.50.1/include/CommonDigest.h.auto.html
     **/
    func sha256(str: String) -> String {
        
        if let strData = str.data(using: String.Encoding.utf8) {
            /// #define CC_SHA256_DIGEST_LENGTH     32
            /// Creates an array of unsigned 8 bit integers that contains 32 zeros
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
            
            /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
            /// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
            strData.withUnsafeBytes {
                // CommonCrypto
                // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
                // OpenSSL                                                                             |
                // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
                CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
            }
            
            var sha256String = ""
            /// Unpack each byte in the digest array and add them to the sha256String
            for byte in digest {
                sha256String += String(format:"%02x", UInt8(byte))
            }
            
            //            if sha256String.uppercased() == "E8721A6EBEA3B23768D943D075035C7819662B581E487456FDB1A7129C769188" {
            //                print("Matching sha256 hash: E8721A6EBEA3B23768D943D075035C7819662B581E487456FDB1A7129C769188")
            //            } else {
            //                print("sha256 hash does not match: \(sha256String)")
            //            }
            return sha256String
        }
        return ""
    }
}
