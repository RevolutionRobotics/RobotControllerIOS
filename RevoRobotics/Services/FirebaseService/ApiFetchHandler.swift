//
//  ApiFetchHandler.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 04. 07..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import PromiseKit
import SwiftyJSON
import Alamofire
import ZIPFoundation

enum ZipType: String {
    case robots, challenges
}

final class ApiFetchHandler {
    // MARK: - Constants
    enum Constants {
        static let apiPath = "api/v1"
        static let deviceNameKey = "robot_id"

        #if TEST
        static let apiUrl = "https://api-test.revolutionrobotics.org/\(apiPath)"
        #elseif DEV
        static let apiUrl = "https://api-test.revolutionrobotics.org/\(apiPath)"
        #else
        static let apiUrl = "https://api-test.revolutionrobotics.org/\(apiPath)"
        #endif
    }

    // MARK: - Properties
    private let userDefaults = UserDefaults.standard

    func fetchAll(callback: @escaping CallbackType<[String: JSON]>) {
        firstly {
            when(fulfilled:
                 fetchPromise(with: "robots"),
                 fetchPromise(with: "challenges"),
                 fetchPromise(with: "firmware"),
                 fetchPromise(with: "versionData"))
        }
        .done { robots, challenges, firmware, versionData in
            let result = [
                "robots": robots,
                "challenges": challenges,
                "firmware": firmware,
                "versionData": versionData
            ]

            callback(result)
        }
        .catch { error in
            error.report()
            print(error)
        }
    }

    func fetch(from type: String, callback: CallbackType<JSON>) {
        firstly {
            fetchPromise(with: type)
        }
        .done { result in
            print(result)
        }
        .catch { error in
            error.report()
            print(error)
        }
    }

    func fetchZip(from urlString: String, type: ZipType, id: String, callback: @escaping Callback) {
        guard
            let url = URL(string: urlString),
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }

        let queue = DispatchQueue(label: "zip_\(id)", qos: .background, attributes: .concurrent)
        let target = documentsDirectory
            .appendingPathComponent(type.rawValue, isDirectory: true)
            .appendingPathComponent(id, isDirectory: true)

        AF.request(url)
            .validate()
            .responseData(queue: queue) { response in
                switch response.result {
                case .success(let data):
                    guard let archive = Archive(data: data, accessMode: .read) else {
                        return
                    }

                    do {
                        try archive.forEach({ entry in
                            _ = try archive.extract(entry, to: target.appendingPathComponent(entry.path))
                        })
                    } catch let error {
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    error.report()
                    print(error.localizedDescription)
                }

                DispatchQueue.main.async {
                    callback()
                }
            }
    }
}

// MARK: - Private methods
extension ApiFetchHandler {
    private func fetchPromise(with endPoint: String) -> Promise<JSON> {
        let queue = DispatchQueue(label: "api_\(endPoint)", qos: .background, attributes: .concurrent)
        let cached = readCached(for: endPoint)

        guard let url = URL(string: "\(Constants.apiUrl)/\(endPoint)") else {
            fatalError("Failed to create url for endpoint: \(endPoint)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("max-age=0, public, must-revalidate", forHTTPHeaderField: "Cache-Control")
        if let cachedEtag = userDefaults.string(forKey: etagKey(for: endPoint)), cached != nil {
            request.setValue(cachedEtag, forHTTPHeaderField: "If-None-Match")
        }
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        return Promise { seal in
            AF.request(request)
                .validate(statusCode: 200..<400)
                .responseJSON(queue: queue) { [weak self] response in
                    if let cached = cached, response.response?.statusCode == 304 {
                        seal.fulfill(cached)
                        return
                    }

                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        if
                            let `self` = self,
                            let etag = response.response?.allHeaderFields["Etag"] as? String {
                            self.userDefaults.set(etag, forKey: self.etagKey(for: endPoint))
                            self.cacheData(for: endPoint, data: json.rawString())
                        }

                        seal.fulfill(json)
                    case .failure(let error):
                        if let cached = cached {
                            seal.fulfill(cached)
                        } else {
                            seal.reject(error)
                        }
                    }
                }
        }
    }

    private func cacheData(for endPoint: String, data: String?) {
        guard let data = data else { return }

        let key = cacheKey(for: endPoint)
        userDefaults.set(data, forKey: key)
    }

    private func readCached(for endPoint: String) -> JSON? {
        let key = cacheKey(for: endPoint)
        guard let jsonString = userDefaults.string(forKey: key) else {
            return nil
        }

        return JSON(parseJSON: jsonString)
    }

    private func etagKey(for object: String) -> String {
        return "etag_\(object)"
    }

    private func cacheKey(for object: String) -> String {
        return "cached_\(object)"
    }
}
