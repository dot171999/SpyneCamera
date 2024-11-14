//
//  RealmManager.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 12/11/24.
//

import Foundation
import RealmSwift

class RealmManager {
    private lazy var realm: Realm = {
        do {
            return try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }()
    
    init() {
        print("init: RealmManager")
    }
    
    deinit {
        print("deinit: RealmManager")
    }
    
    func add<T: Object>(object: T) throws {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            throw RealmError.unabelToAddObject(error)
        }
    }
    
    func readAll<T: Object>() -> Results<T> {
        return realm.objects(T.self)
    }
    
    func objectForKey<T: Object>(primaryKey: String) -> T?  {
        return realm.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    
    func update(_ block: () -> Void) throws {
        do {
            try realm.write {
                block()
            }
        } catch {
            throw RealmError.unableToWriteUpdates(error)
        }
    }
}
