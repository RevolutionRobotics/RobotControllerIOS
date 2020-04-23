//
//  RealmConnector.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift
import os

final class RealmConnector {
    // MARK: - Constants
    private enum Constants {
        static let realmName = "RevolutionRobotics"
        static let realmExtension = ".realm"
    }

    // MARK: - Properties
    var realm: Realm!
    private var path: URL {
        return FileManager.documentsDirectory.appendingPathComponent(Constants.realmName + Constants.realmExtension)
    }

    // MARK: - Initialization
    init() {
        connectToRealm()
    }
}

// MARK: - RealmConnectorInterface
extension RealmConnector: RealmConnectorInterface {
    func find<T>(type: T, predicate: NSPredicate) -> [T] where T: Object {
        return []
    }

    func connectToRealm() {
        do {
            self.realm = try Realm(configuration: realmConfiguration())
        } catch {
            os_log("Error: Failed to connect to the local database!")
        }
    }

    func deleteRealm() {
        guard FileManager.default.fileExists(atPath: path.relativePath) else { return }
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            os_log("Error: Failed to delete the local database!")
        }
    }

    func findAll(type: Object.Type) -> [Object] {
        realm.refresh()
        return Array(realm.objects(type))
    }

    func find(type: Object.Type, predicate: NSPredicate) -> [Object] {
        realm.refresh()
        return Array(realm.objects(type).filter(predicate))
    }

    func save<T: Object>(object: T, shouldUpdate: Bool) {
        realm.refresh()
        do {
            try self.realm.write {
                if shouldUpdate {
                    realm.add(object, update: .all)
                } else {
                    realm.add(object)
                }
            }
        } catch {
            os_log("Error: Could not save object to the local database!")
        }
    }

    func save<T: Object>(objects: [T], shouldUpdate: Bool) {
        realm.refresh()
        do {
            try self.realm.write {
                if shouldUpdate {
                    realm.add(objects, update: .all)
                } else {
                    realm.add(objects)
                }
            }
        } catch {
            os_log("Error: Could not save objects to the local database!")
        }
    }

    func delete<T: Object>(object: T?) {
        guard let object = object else { return }
        realm.refresh()
        do {
            try self.realm.write {
                realm.delete(object)
            }
        } catch {
            os_log("Error: Could not delete object from the local database!")
        }
    }

    func delete<T: Object>(objects: [T]) {
        realm.refresh()
        do {
            try self.realm.write {
                realm.delete(objects)
            }
        } catch {
            os_log("Error: Could not delete objects from the local database!")
        }
    }
}

// MARK: - Private methods
extension RealmConnector {
    private func realmConfiguration() -> Realm.Configuration {
        return Realm.Configuration(
            fileURL: path,
            readOnly: false,
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true)
    }

    private func excludeRealmFromBackup() {
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            var fileURL = path
            try fileURL.setResourceValues(resourceValues)
        } catch {
            os_log("Error: Could not exclude local database from backup!")
        }
    }
}
