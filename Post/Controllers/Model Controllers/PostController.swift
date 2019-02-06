//
//  PostController.swift
//  Post
//
//  Created by XMS_JZhan on 2/4/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class PostController {
    
    private let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    init() {
        self.posts = []
    }
    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        guard let url = baseURL else { fatalError("URL optional is having issues") }
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimeStamp ?? Date().timeIntervalSince1970
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            completion()
            return
        }

        let getterEndpoint = finalURL.appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: getterEndpoint)
        urlRequest.httpMethod = "GET"
        urlRequest.httpBody = nil
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("Error obtaining data: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = data else {
                completion()
                return
            }
            
            // JSON Decoder
            let jsonDecoder = JSONDecoder()
            do {
                let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                var posts = postsDictionary.compactMap({ $0.value })
                posts.sort(by: { $0.timestamp > $1.timestamp })
                
                if reset {
                    self.posts = posts
                } else {
                    self.posts.append(contentsOf: posts)
                }
                completion()
                return
            } catch {
                print("Error decoding: \(error.localizedDescription)")
                completion()
                return
            }
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping (() -> Void)) {
        let post = Post(text: text, username: username)
        var postData = Data()
        
        do {
            let jsonEndcoder = JSONEncoder()
            postData = try jsonEndcoder.encode(post)
            
        } catch {
            
        }
        guard let url = baseURL else { fatalError("URL optional is having issues") }
        let postEndpoint = url.appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: postEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = data else {
                print("")
                completion()
                return
            }
            
            let returnData = String(data: data, encoding: .utf8)
            print("\(returnData)")
            self.fetchPosts(completion: {
                completion()
            })
            
        }
        dataTask.resume()
    }
}
