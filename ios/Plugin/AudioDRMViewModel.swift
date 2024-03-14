//
//  AudioDRMViewModel.swift
//  Plugin
//
//  Created by Parth Sheth on 14/02/24.
//  Copyright © 2024 Max Lynch. All rights reserved.
//

import Foundation

class AudioDRMViewModel
{
    var audioDRMToken = ""
    var licenseURI: String = ""
    var tempIndex: Int = 0
    var tempUrl: String = ""
    var secondURL = ""
    var currentSkd = ""

    func getSkdWithAlamofire(url: String, completion: @escaping (Bool) -> Void)
    {
        guard let escapedString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let urlString = URL(string: escapedString) else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlString) { [weak self] data, response, error in
            if let error = error {
                print("Get Skd With URLSession Error: \(error)")
                completion(false)
                return
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                completion(false)
                return
            }
            
            self?.licenseURI = responseString
            completion(true)
        }
        
        task.resume()
    }

    func processLicenseURI(_ licenseURI: String, originalUrl: String,completion: @escaping (Bool) -> Void) {
    
    self.licenseURI = licenseURI
    
        DispatchQueue.main.async { [self] in
        self.tempIndex = getIndexOfSubString(fullString: self.licenseURI, searchString: "URI")
        self.licenseURI = String(self.licenseURI.dropFirst(self.tempIndex))
        self.tempIndex =  getIndexOfSubString(fullString: self.licenseURI, searchString: "#EXT")
        self.licenseURI = String(self.licenseURI.dropLast(self.licenseURI.count - self.tempIndex))
        self.licenseURI = String(self.licenseURI.dropFirst(5))
        self.licenseURI = self.licenseURI.trimmingCharacters(in: .whitespacesAndNewlines)
        self.licenseURI = String(self.licenseURI.dropLast(1))
            print(self.licenseURI)
        self.tempIndex = getIndexOfSubString(fullString: originalUrl, searchString: ".ism/")
        self.tempUrl = String(originalUrl.dropLast(originalUrl.count - (self.tempIndex + 5)))
        
        guard let escapedString = self.tempUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let urlString = URL(string: escapedString) else {
            completion(false)
            return
        }
        

            secondURL = "\(urlString)\(self.licenseURI)"
        // print(secondURL)
            completion(true)
    }
}

    func getSkdFromSecondURL(url: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: url) else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                completion(false)
                return
            }
            
            self?.licenseURI = responseString

            if let keyDeliveryURL = self?.extractKeyDeliveryURL(from: responseString) {
                self?.currentSkd = keyDeliveryURL
                completion(true)
            } else {
                // print("Key Delivery URL not found.")
                completion(false)
            }
        }

        task.resume()
    }

    func extractKeyDeliveryURL(from response: String) -> String? {
        let pattern = #"URI="(skd:\/\/[^"]+)"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(response.startIndex..<response.endIndex, in: response)
            if let match = regex.firstMatch(in: response, options: [], range: range) {
                let nsRange = match.range(at: 1)
                if let range = Range(nsRange, in: response) {
                    return String(response[range])
                }
            }
        } catch {
            print("Error creating regex: \(error)")
        }
        return nil
    }
    
    func getIndexOfSubString(fullString: String, searchString: String) -> Int {
        if let range = fullString.range(of: searchString) {
            return fullString.distance(from: fullString.startIndex, to: range.lowerBound)
        }
        return 0
    }
}



