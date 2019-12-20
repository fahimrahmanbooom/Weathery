//
//  ViewController.swift
//  Weathery
//
//  Created by Fahim Rahman on 9/12/19.
//  Copyright © 2019 Fahim Rahman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    // Outlets
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherIconImage: UIImageView!
    @IBOutlet weak var locationInputTextField: UITextField!
    
    // Your API KEY. Get it from open weather map website.
    
    let apikey = ""
    
    // Variables
    
    var temperature: Int?
    var city: String?
    var location: String?
    var currentLocation: String?
    var conditionId: Int?
    
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationInputTextField.delegate = self
        locationService()
        location = "\(currentLocation ?? "")"
        getDataFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationService()
        getDataFromServer()
    }
    
    // Search Button Action
    
    @IBAction func searchPressed(_ sender: UIButton) {
        
        if locationInputTextField.text != "" {
        
        location = locationInputTextField.text
        location = "q=\(location!)"
        getDataFromServer()
        }
        else {
            locationService()
            location = "\(currentLocation ?? "")"
            getDataFromServer()
        }
        locationInputTextField.endEditing(true)
        locationInputTextField.resignFirstResponder()
    }
    
    // Location Button Action
    
    @IBAction func locationPressed(_ sender: UIButton) {
        
        locationService()
        location = "\(currentLocation ?? "")"
        getDataFromServer()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        location = locationInputTextField.text
        location = "q=\(location!)"
        getDataFromServer()
        locationInputTextField.endEditing(true)
        locationInputTextField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if locationInputTextField.text != "" {
            return true
        }
        else {
            locationInputTextField.placeholder = "Enter a city name here"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        locationInputTextField.text = ""
    }
    
    
    // Getting Weather Data From OPEN WEATHER MAP Server
    
    func getDataFromServer() {
        AF.request("https://api.openweathermap.org/data/2.5/weather?\(location!)&appid=\(apikey)").validate().responseJSON { response in
            
            let json = JSON(response.value as Any)
            
            self.city = json["name"].string
            self.temperature = json["main"]["temp"].int
            self.conditionId = json["weather"][0]["id"].int
            
            if self.temperature != nil {
                self.temperature! -=  273
                self.temperatureLabel.text = "\(self.temperature!)° C"
            }
            else {
                self.temperatureLabel.text = "° C"
            }
            
            
            if self.city != nil {
                self.locationLabel.text = "\(self.city!)"
            }
            else {
                self.locationLabel.text = "Not Found"
            }
            
            if self.conditionId != nil {
                
                if self.conditionId! >= 200 && self.conditionId! <= 232 {
                 self.weatherIconImage.image = UIImage(systemName: "cloud.bolt")
                }
                if self.conditionId! >= 300 && self.conditionId! <= 321 {
                    self.weatherIconImage.image = UIImage(systemName: "cloud.drizzle")
                }
                if self.conditionId! >= 500 && self.conditionId! <= 531 {
                    self.weatherIconImage.image = UIImage(systemName: "cloud.rain")
                }
                if self.conditionId! >= 600 && self.conditionId! <= 622 {
                    self.weatherIconImage.image = UIImage(systemName: "cloud.snow")
                }
                if self.conditionId! >= 701 && self.conditionId! <= 781 {
                    self.weatherIconImage.image = UIImage(systemName: "cloud.fog")
                }
                if self.conditionId! >= 800 && self.conditionId! <= 801 {
                    self.weatherIconImage.image = UIImage(systemName: "sun.max")
                }
                if self.conditionId! >= 801 && self.conditionId! <= 804 {
                    self.weatherIconImage.image = UIImage(systemName: "cloud.bolt")
                }
            }
            else {
                self.weatherIconImage.image = UIImage(systemName: "cloud")
            }
        }
    }

    // Taking permission from the user to get the current location
    
    func locationService() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            reportLocationServicesDeniedError()
            return
        }
        
        else {
            locationUpdated()
        }
    }
    
    // Getting the location from the user's phone
    
    func locationUpdated() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
            
            currentLocation = "lat=\(locationManager.location?.coordinate.latitude ?? 0)&lon=\(locationManager.location?.coordinate.longitude ?? 0)"
        }
    }
    
    // Letting user know that he/she did't give permission
    
    func reportLocationServicesDeniedError() {
        let alert = UIAlertController(title: "Location Service Disabled.", message: "Please go to Setting > Privacy to enable location service for this app.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
