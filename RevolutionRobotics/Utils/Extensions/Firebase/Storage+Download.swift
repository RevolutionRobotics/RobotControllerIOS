//
//  Storage+Download.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 07..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Firebase

extension Storage {
    func store(resourceName: String, as name: String) {
        self.reference(forURL: resourceName).downloadURL { url, error in
            guard error == nil, let url = url else { return }
            do {
                try FileManager.default.save(Data(contentsOf: url), as: name)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
