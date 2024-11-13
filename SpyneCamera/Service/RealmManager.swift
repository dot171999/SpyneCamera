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
    
    @discardableResult
    func add<T: Object>(object: T) -> Result<Bool, Error> {
        do {
            try realm.write {
                realm.add(object)
            }
            return .success(true)
        } catch {
            print("error writing to realm: ", error)
            return .failure(error)
        }
    }
    
    func readAll<T: Object>() -> Results<T> {
        return realm.objects(T.self)
    }
    
    func objectForKey<T: Object>(primaryKey: String) -> T?  {
        return realm.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    
    func update(_ block: () -> Void) {
        do {
            try realm.write {
                block()
            }
        } catch {
            // to do
        }
    }
}
