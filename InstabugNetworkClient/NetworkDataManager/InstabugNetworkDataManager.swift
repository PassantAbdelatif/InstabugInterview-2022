//
//  CoreDataManager.swift
//  CoreDataFramework
//
//  Created by Passant Abdelatif on 22/10/2022.
//

import Foundation
import CoreData

public class InstabugNetworkDataManager {
    public static let shared = InstabugNetworkDataManager()
    //Your framework bundle ID
    let identifier: String  = "com.Instabug.InstabugNetworkClient"
    //Model name
    let model: String       = "CoreDataModel"
    
    lazy var mainContext = persistentContainer.viewContext
    lazy var backgroundContext = persistentContainer.newBackgroundContext()
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let messageKitBundle = Bundle(identifier: self.identifier)
        let modelURL = messageKitBundle!.url(forResource: self.model,
                                             withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentCloudKitContainer(name: self.model,
                                                      managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { (storeDescription, error) in
            
            if let err = error{
                fatalError("❌ Loading of store failed:\(err)")
            }
        }
        return container
    }()
    
    
    func insert<T: NSManagedObject>(object: T) {
        // unsafe
       // let context = persistentContainer.viewContext
        
        // Perform operations on the background context
        // asynchronously
        self.backgroundContext.perform {
            do {
                self.backgroundContext.insert(object)
                try self.backgroundContext.save()
                print("✅ saved succesfuly")
            } catch let error as NSError {
                print("❌ Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    public func fetch<T: NSManagedObject>(entity: T.Type) -> [T]? {
        
        var results: [T]?
        
        // Perform operations on the background context
        // synchronously
        self.backgroundContext.performAndWait {
            
            if let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> {
                do {
                    results = try self.backgroundContext.fetch(fetchRequest)
                } catch let fetchErr {
                    print("❌ Failed to fetch request:",fetchErr)
                }
            } else {
                assert(false,"Error: cast to NSFetchRequest<T> failed")
            }
        }
        return results
    }
    
    public func deleteAllRecords<T: NSManagedObject>(entity: T.Type) {
      
        // Perform operations on the background context
        // asynchronously
        self.backgroundContext.perform {
            if let results = self.fetch(entity: entity),
               results.count > 0 {
                
                do{
                    results.forEach { request in
                        self.backgroundContext.delete(request)
                    }
                    try self.backgroundContext.save()
                    
                }catch let fetchErr {
                    print("❌ Failed to fetch request:",fetchErr)
                }
            }
        }
    }
    
    public func deleteFirstRecord<T: NSManagedObject>(entity: T.Type) {
     
        // Perform operations on the background context
        // asynchronously
        self.backgroundContext.perform {
            if let results = self.fetch(entity: entity),
               results.count > 0 {
                
                do{
                    if let firstRecord = results.first {
                        self.backgroundContext.delete(firstRecord)
                        try self.backgroundContext.save()
                    }
                    
                }catch let fetchErr {
                    print("❌ Failed to fetch request:",fetchErr)
                }
            }
        }
    }
}
