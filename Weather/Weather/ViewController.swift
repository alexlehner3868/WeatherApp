//
//  ViewController.swift
//  weather
//
//  Created by Alexander Lehner on 2020-04-30.
//  Copyright © 2020 LiveWeatherLove. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let apiKey = "81e6543ba7cb97c6a55d1c8dd855bd61"
    var lat = 11.344533
    var lon = 104.33322
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
  
    //variables for the algorithm given from API call
    var temperature = 0
    var tempFeelsLike = 0
    var humidity = 0
    var windSpeed = 0
    var clouds = 0
    var weatherMainDescription = ""
    var weatherSubDescription = ""
    var weatherIcon = ""
    var weatherID = 0;
    var rainVol = 0
    var snowVolume = 0
    
    //sets the limits of what clothing to wear
    var temperatureLimit:[String:Int] = [
    "freezing": 0,
    "cold": 7,
    "warm": 18,
    "hot": 26,
    ]
   
    //which clothing shows
    var hat = ""
    var top = ""
    var bottoms = ""
    var shoes = ""
    
    //Connects Items to story board
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var contitionImageView: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    //clothing items
    @IBOutlet weak var hatImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var shoesImageView: UIImageView!
    
    let gradientLayer = CAGradientLayer()
      

    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        //getting user location
        locationManager.requestWhenInUseAuthorization()
        
        
         if(CLLocationManager.locationServicesEnabled()){
                   locationManager.delegate = self
                   locationManager.desiredAccuracy = kCLLocationAccuracyBest
                   locationManager.startUpdatingLocation()
               }

        

    }
    
    //updating location
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.isEmpty == false {
            let location = locations[0]
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
        }
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON {
                   response in
                   
                   if let responseStr = response.result.value {
                    let jsonResponse = JSON(responseStr)
                    
                    //Main dictionary keys
                    let jsonWeather = jsonResponse["weather"].array![0]
                    let jsonMain = jsonResponse["main"]
                    let jsonWind = jsonResponse["wind"]
                    let jsonClouds = jsonResponse["clouds"]
                    let jsonSys = jsonResponse["sys"]
                    let jsonRain = jsonResponse["rain"]
                    let jsonSnow = jsonResponse["snow"]
                    
                    //Data from "weather" key
                    self.weatherMainDescription = jsonWeather["main"].stringValue
                    self.weatherSubDescription = jsonWeather["description"].stringValue
                    self.weatherIcon = jsonWeather["icon"].stringValue
                    self.weatherID = jsonWeather["id"].intValue;
                    
                    //Data from "main" key
                    self.temperature = Int(round(jsonMain["temp"].doubleValue))
                    self.tempFeelsLike = Int(round(jsonMain["temp"].doubleValue))
                    self.humidity = jsonMain["humidity"].intValue
                    
                    //Data from "wind" key
                    self.windSpeed = jsonWind["speed"].intValue
                    
                    //Data from "clouds" key
                    self.clouds = jsonClouds["all"].intValue
         
                    //Data from "rain" key
                    self.rainVol = jsonRain["rain.1h"].intValue
                    
                    //Data from "snow" key
                    self.snowVolume = jsonSnow["snow.1h"].intValue
                
                    //Change to F if in the US
                    let country = jsonSys["country"].stringValue
                    var temperature = self.temperature
                    var units = "°C"
                    if(country == "US"){
                        temperature = (temperature * 9 / 5) + 32
                        units = "°F"
                    }
                    //here is where we would get the other pieces of info on weather to calculate what to wear
                //to see what other info is available put the url in google and replace lat, lon, and api with values
                    
                    //decide what elements to wear
                    self.whichClothesToWear()
                    
                    //updating elements on screen with new values
                    self.locationLabel.text = jsonResponse["name"].stringValue
                    self.contitionImageView.image = UIImage(named: self.weatherIcon)
                    self.conditionLabel.text = jsonWeather["main"].stringValue
                    self.temperatureLabel.text = "\(temperature)"
                    self.unitLabel.text = "\(units)"
                    
                    
                    //set clothing
                    self.topImageView.image = UIImage(named: self.top)
                   self.bottomImageView.image = UIImage(named: self.bottoms)
                    self.shoesImageView.image = UIImage(named: self.shoes)
                    if(self.hat != ""){
                         self.hatImageView.image = UIImage(named: self.hat)
                    }
                    
                   
                    
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE"
                    self.dayLabel.text = dateFormatter.string(from: date)

                    //changes background color depending on time of day
                    let suffix = self.weatherIcon.suffix(1)
                    if(suffix == "n"){
                        self.setGreyGradientBackground()
                    }else{
                        self.setBlueGradientBackground()
                    }
            }
        }
        self.locationManager.stopUpdatingLocation()
     }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    //make the background appear like a gradient
    override func viewWillAppear(_ animated: Bool) {
           setBlueGradientBackground()
       }
    //sets background to blue gradient
    func setBlueGradientBackground(){
           let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
           let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
           gradientLayer.frame = view.bounds
           gradientLayer.colors = [topColor, bottomColor]
       }
       
       func setGreyGradientBackground(){
           let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
           let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
           gradientLayer.frame = view.bounds
           gradientLayer.colors = [topColor, bottomColor]
       }

    
        func whichClothesToWear(){
            if(self.tempFeelsLike <= temperatureLimit["freezing"]!){
                self.hat = "winter_hat"
                self.top = "winter_coat"
                self.bottoms = "pants"
            }else if(self.tempFeelsLike <= temperatureLimit["cold"]! && self.tempFeelsLike > temperatureLimit["freezing"]!){
                self.hat = ""
                self.top = "winter_coat"
                self.bottoms = "pants"
            }else if(self.tempFeelsLike <= temperatureLimit["warm"]! && self.tempFeelsLike > temperatureLimit["cold"]!){
                self.hat = ""
                self.top = "long_sleeve_shirt"
                self.bottoms = "pants"
            }else if(self.tempFeelsLike <= temperatureLimit["hot"]! && self.tempFeelsLike > temperatureLimit["warm"]!){
                self.hat = ""
                self.top = "t_shirt"
                self.bottoms = "pants"
            }else if(self.tempFeelsLike > temperatureLimit["hot"]! ){
                self.hat = "baseball_cap"
                self.top = "t_shirt"
                self.bottoms = "shorts"
            }
            
            if(self.snowVolume > 100){
                self.shoes = "boots"
            }else {
                 self.shoes = "sneakers"
            }
        }
}


