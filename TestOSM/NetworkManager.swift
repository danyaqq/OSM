//
//  NetworkManager.swift
//  TestOSM
//
//  Created by Student on 18.03.2022.
//

import Foundation

enum Methods: String, CaseIterable {
    case get = "GET"
    case posts = "POST"
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func baseRequest<T: Decodable>(url: String, method: Methods, model: T?, completion: @escaping(T) -> Void) {
        guard let url = URL(string: url) else {
            return
        }
        
        let parameters: [String: Any] = [
            "request": [
                "xusercode" : "YOUR USERCODE HERE",
                "xpassword": "YOUR PASSWORD HERE"
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                return
            }
            if let model = model {
                do {
                    let decodedData = try JSONDecoder().decode(model.self as! T.Type, from: data)
                    completion(decodedData)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}
