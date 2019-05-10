//
//  URLSession+ImageDownload.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

extension URLSession {
    func downloadImage(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
