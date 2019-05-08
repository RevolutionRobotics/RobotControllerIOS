//
//  FileManager+Documents.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

extension FileManager {
    private enum Constants {
        static let documentsDirectoryName = "Documents"
    }

    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        if !documentsDirectoryExists(at: documentsDirectory) {
            createDocumentsDirectory(at: documentsDirectory)
        }
        return documentsDirectory
    }

    private static func createDocumentsDirectory(at path: URL) {
        let newPath = path.deletingLastPathComponent()
        let documents = newPath.appendingPathComponent(Constants.documentsDirectoryName)
        do {
            try FileManager.default.createDirectory(atPath: documents.relativePath,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    private static func documentsDirectoryExists(at path: URL) -> Bool {
        var isDir: ObjCBool = true
        let str = path.absoluteString
        return FileManager.default.fileExists(atPath: str, isDirectory: &isDir)
    }
}
