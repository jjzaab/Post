//
//  Post.swift
//  Post
//
//  Created by XMS_JZhan on 2/4/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

struct Post: Codable {
    
    var text: String
    var timestamp: TimeInterval
    var username: String
    var queryTimeStamp: TimeInterval {
        return self.timestamp + 0.00001
    }
    
    init(text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, username: String) {
        self.text = text
        self.username = username
        self.timestamp = timestamp
    }
}
