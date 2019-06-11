//
//  FileManager+Documents.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import UIKit
import os

extension FileManager {
    private enum Constants {
        static let documentsDirectoryName = "Documents"
        static let programsDirectoryName = "Programs"
        static let jpegExtension = ".jpeg"
        static let compressionQuality: CGFloat = 0.5
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
        } catch {
            os_log("Error: Could not create documents directory!")
        }
    }

    private static func documentsDirectoryExists(at path: URL) -> Bool {
        var isDir: ObjCBool = true
        let str = path.absoluteString
        return FileManager.default.fileExists(atPath: str, isDirectory: &isDir)
    }
}

// MARK: - Image saving
extension FileManager {
    func save(_ data: Data?, as name: String) {
        guard let data = data else { return }
        let path = FileManager.documentsDirectory.appendingPathComponent(name)
        do {
            try data.write(to: path)
        } catch {
            os_log("Error: Could not save data in documents directory!")
        }
    }

    func open(name: String?) -> Data? {
        guard let name = name else { return nil }
        let url = URL(string: FileManager.documentsDirectory.appendingPathComponent(name).absoluteString)!
        return try? Data(contentsOf: url)
    }

    func save(_ image: UIImage?, as name: String) {
        guard let image = image,
            let data = image.jpegData(compressionQuality: Constants.compressionQuality) else {
                return
        }
        let path = FileManager.documentsDirectory.appendingPathComponent(name + Constants.jpegExtension)
        do {
            try data.write(to: path)
        } catch {
            os_log("Error: Could not save image in documents directory!")
        }
    }

    func delete(name: String?) {
        guard let name = name else { return }
        let path = FileManager.documentsDirectory.appendingPathComponent(name + Constants.jpegExtension)
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            os_log("Error: Could not delete data from documents directory!")
        }
    }

    func image(for robotId: String?) -> UIImage? {
        guard let robotId = robotId else { return nil }
        let path = FileManager.documentsDirectory.appendingPathComponent(robotId + Constants.jpegExtension).relativePath
        return UIImage(contentsOfFile: path)
    }
}
