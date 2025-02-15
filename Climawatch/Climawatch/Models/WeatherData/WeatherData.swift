//
//  WeatherData.swift
//  Climawatch
//
//  Created by William Judd on 10/10/19.
//  Copyright © 2019 Opulent Apps. All rights reserved.
//

import Foundation

protocol WeatherDataDelegate {
    func didUpdateWeather(_ weatherData: WeatherData, model: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherData {
    
    let weatherDataURL = "https://api.openweathermap.org/data/2.5/weather?appid=4c77d4f0c775415b96621bbe71a98fae&units=imperial"
    
    var delegate: WeatherDataDelegate?
    
    func fetchWeather(cityName: String) {
        let dataURL = "\(weatherDataURL)&q=\(cityName)"
        fetchData(dataUrl: dataURL)
        print(dataURL)
    }
    
    func fetchWeather(longitude: Double, latitude: Double) {
        let dataURL = "\(weatherDataURL)&lat=\(latitude)&lon=\(longitude)"
        fetchData(dataUrl: dataURL)
        print(dataURL)
    }
    
    func fetchData(dataUrl: String) {
        if let url = URL(string: dataUrl) {
            
            let session = URLSession(configuration: .default)
            let dataTask = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let returnData = data {
                    if let weather = self.parseJson(returnData) {
                        print(weather.temperatureString)
                        self.delegate?.didUpdateWeather(self, model: weather)
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    func parseJson(_ data: Data) -> WeatherModel? {
        let decodeJson = JSONDecoder()
        do {
            let decodedData = try decodeJson.decode(WeatherManager.self, from: data)
            let decName = decodedData.name
            let decTemp = decodedData.main.temp
            let decId = decodedData.weather[0].id
            let weather = WeatherModel(cityName: decName, cityTemp: decTemp, cityId: decId)
            return weather
        } catch  {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    //: END
}
