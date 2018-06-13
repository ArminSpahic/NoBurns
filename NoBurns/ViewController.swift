//
//  ViewController.swift
//  NoBurns
//
//  Created by Armin Spahic on 27/05/2018.
//  Copyright © 2018 Armin Spahic. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var skinTypeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var changeBtnLabel: UIButton!
   
    @IBOutlet var myView: UIView!
    @IBOutlet weak var timeToBurnLabel: UILabel!
    @IBOutlet weak var messageLabelLeading: NSLayoutConstraint!
    var coords = CLLocationCoordinate2D(latitude: 40, longitude: 40)
    let locationManager = CLLocationManager()
    var timer = Timer()
    var seconds: Double = 0
    var minutes: Double = 0
    let fiveDayURL = "https://api.openweathermap.org/data/2.5/forecast"
    let baseURL = "https://api.openweathermap.org/data/2.5/uvi"
    let apiKey = "a5bb9049795e82d079c45daa67a5d713"
    var skinType = SkinType().type1 {
        didSet {
            skinTypeLabel.text = "Skin: " + self.skinType
            Utilities().setSkinType(value: skinType)
            getLocation()
            runTimer()
        }
    }
    var uvIndex: Double = 8
    var burnTime: Double = 10
    var tapGesture = UITapGestureRecognizer()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        skinType = Utilities().getSkinType()
        skinTypeLabel.text = "Skin: " + skinType
        
        self.myView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose(gesture:))))
        self.myView.isUserInteractionEnabled = true
        
      
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            getLocation()
        } else if status == .denied {
            let alert = UIAlertController(title: "Error", message: "In order for this app to work you need to change the location status in your settings!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func getLocation() {
        if let loc = locationManager.location?.coordinate {
            coords = loc
            
            let lat = String(coords.latitude)
            let lon = String(coords.longitude)
            print("Coords are: \(lon,lat)")
            let params : [String : String] = ["lat" : lat, "lon" : lon, "appid" : apiKey]
            getWeatherData(url: baseURL, parameters: params)
           
           
        }
    }
    @objc func alertClose(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

    @IBAction func changeBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Skin type", message: "Choose your skin type", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: SkinType().type1, style: .default, handler: { (action) in
            self.skinType = SkinType().type1
        }))
        alert.addAction(UIAlertAction(title: SkinType().type2, style: .default, handler: { (action) in
            self.skinType = SkinType().type2
        }))
        alert.addAction(UIAlertAction(title: SkinType().type3, style: .default, handler: { (action) in
            self.skinType = SkinType().type3
        }))
        alert.addAction(UIAlertAction(title: SkinType().type4, style: .default, handler: { (action) in
            self.skinType = SkinType().type4
        }))
        alert.addAction(UIAlertAction(title: SkinType().type5, style: .default, handler: { (action) in
            self.skinType = SkinType().type5
        }))
        alert.addAction(UIAlertAction(title: SkinType().type6, style: .default, handler: { (action) in
            self.skinType = SkinType().type6
        }))
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose(gesture:))))
            
            
        }
           
        
        
    }
    
    @IBAction func setReminderBtnPressed(_ sender: UIButton) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "Times's Up", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "You are beginning to burn. Please get away from sun", arguments: nil)
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: self.burnTime*60, repeats: false)
                let request = UNNotificationRequest(identifier: "willburn", content: content, trigger: trigger)
                center.add(request, withCompletionHandler: nil)
                
            }
        }
    }
    
    func getWeatherDataForFiveDays(url: String, parameters: [String : String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Got the 5 day data")
                let weatherFiveJSON : JSON = JSON(response.result.value)
                print(weatherFiveJSON)
                
            } else {
                print("5 days data error")
            }
        }
        
    }
    func getWeatherData(url: String, parameters: [String : String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                //print("Got the weather data!")
                let weatherJSON : JSON = JSON(response.result.value)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
                
            } else {
                print("Error \(response.result.error)")
                
                
            }
        }
    }
    
    func updateWeatherData(json: JSON) {
        if let uvI = json["value"].double {
            uvIndex = uvI
            print("UVIndex is: \(uvI)")
            updateUI(dataSuccess: true)
        } else {
            print("Error getting UV index")
            updateUI(dataSuccess: false)
        }
    }
    
    func changeB() {
        switch minutes {
        case 1:
            minutes < 5
                timeToBurnLabel.text = ""
            
        default:
            timeToBurnLabel.text = String(format: "%.1f", minutes)
        }
    }

    func updateUI(dataSuccess: Bool) {
        
        if dataSuccess != true {
            messageLabel.text = "Error getting data...Retrying..."
           getLocation()
            
            
        } else {
            activityIndicator.stopAnimating()
            messageLabel.text = "Got the UV data"
            calculateBurnTime()
          //  timeToBurnLabel.text = String(format: "%.0f", burnTime)
            
            
          
            
            
            
            
        }
    }
  
    
    func calculateBurnTime() {
        var burnIndex : Double = 10
        switch skinType{
        case SkinType().type1:
            burnIndex = BurnTime().burnType1
        case SkinType().type2:
             burnIndex = BurnTime().burnType2
        case SkinType().type3:
             burnIndex = BurnTime().burnType3
        case SkinType().type4:
             burnIndex = BurnTime().burnType4
        case SkinType().type5:
             burnIndex = BurnTime().burnType5
        case SkinType().type6:
             burnIndex = BurnTime().burnType6
        default:
             burnIndex = BurnTime().burnType1
        }
        burnTime =  burnIndex/Double(uvIndex)
        print("Burn time : \(burnTime)")
        seconds = burnTime * 60
       
        
        
        
    }
    
    @objc func updateTimer() {
        seconds -= 1
        minutes = seconds/60
        changeB()
        if minutes == 0 {
            timer.invalidate()
            timeToBurnLabel.text = "Get away from the sun or put any kind of sun protection"
            
        }
        timeToBurnLabel.text = String(format: "%.1f", minutes)
        
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        
        
    }
    
  
  
    
    

}
