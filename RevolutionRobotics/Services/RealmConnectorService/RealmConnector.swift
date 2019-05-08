//
//  RealmConnector.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

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
            print("❌ Could not connect to local database!")
        }
    }

    func deleteRealm() {
        guard FileManager.default.fileExists(atPath: path.relativePath) else { return }
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            print("❌ Could not delete local database!")
        }
    }

    func findAll(type: Object.Type) -> [Object] {
        return Array(realm.objects(type))
    }

    func find(type: Object.Type, predicate: NSPredicate) -> [Object] {
        return Array(realm.objects(type).filter(predicate))
    }

    func save<T: Object>(object: T, shouldUpdate: Bool) {
        realm.refresh()
        do {
            try self.realm.write {
                realm.add(object, update: shouldUpdate)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func save<T: Object>(objects: [T], shouldUpdate: Bool) {
        realm.refresh()
        do {
            try self.realm.write {
                realm.add(objects, update: shouldUpdate)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func delete<T: Object>(object: T) {
        realm.refresh()
        do {
            try self.realm.write {
                realm.delete(object)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func delete<T: Object>(objects: [T]) {
        realm.refresh()
        do {
            try self.realm.write {
                realm.delete(objects)
            }
        } catch {
            print(error.localizedDescription)
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
            print("❌ Could not exclude local database from backup!")
        }
    }
}
