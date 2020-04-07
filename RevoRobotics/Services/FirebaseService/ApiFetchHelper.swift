//
//  ApiFetchHelper.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 04. 07..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import PromiseKit
import SwiftyJSON
import Alamofire

final class ApiFetchHelper {
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

    func fetchAll(callback: @escaping CallbackType<JSON>) {
        firstly {
            when(fulfilled:
                 fetchPromise(with: "robots"),
                 fetchPromise(with: "challenges"),
                 fetchPromise(with: "firmware"))
        }
        .done { robots, challenges, firmware in
            let result = JSON([
                "robots": robots,
                "challenges": challenges,
                "firmware": firmware
            ])

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

    private func fetchPromise(with endPoint: String) -> Promise<JSON> {
        let queue = DispatchQueue(label: "api_\(endPoint)", qos: .background, attributes: .concurrent)

        return Promise { seal in
            AF.request("\(Constants.apiUrl)/\(endPoint)")
                .validate(statusCode: 200..<400)
                .responseJSON(queue: queue) { response in
                    guard response.response?.statusCode != 304 else {
                        seal.fulfill(JSON())
                        return
                    }

                    switch response.result {
                    case .success(let data):
                        seal.fulfill(JSON(data))
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }
}
