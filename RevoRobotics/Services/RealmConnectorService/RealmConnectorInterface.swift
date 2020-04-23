//
//  RealmConnectorInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

protocol RealmConnectorInterface {
    var realm: Realm! { get }

    func connectToRealm()
    func deleteRealm()
    func findAll(type: Object.Type) -> [Object]
    func find(type: Object.Type, predicate: NSPredicate) -> [Object]
    func save<T: Object>(object: T, shouldUpdate: Bool)
    func save<T: Object>(objects: [T], shouldUpdate: Bool)
    func delete<T: Object>(object: T?)
    func delete<T: Object>(objects: [T])
}
