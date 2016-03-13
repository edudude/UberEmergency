//
//  CoreDataHandler.swift
//  UberTest
//
//  Created by Kyle Haptonstall on 3/12/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHandler{
    // Core Data Methods
    
    let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func saveNewObjectForName(entityName name:String, withValues values: [String: AnyObject]) -> Bool{
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let newObject = NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: context) as NSManagedObject
        
        
        for (key, value) in values{
            newObject.setValue(value, forKey: key)
        }
        
        do{
            try context.save()
        }
        catch{
            print("Unable to save new object")
            return false
        }
        
        return true
    }
    
    
    func updateObject(withEntityName name: String, andValues values: [String:AnyObject]) -> Bool{
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Contact")
        request.returnsObjectsAsFaults = false
        do{
            let results = try context.executeFetchRequest(request)
            if results.count == 1 {
                let objectToUpdate = results[0]
                
                for (key, value) in values{
                    objectToUpdate.setValue(value, forKey: key)
                }
                
                do{ try context.save() }
                catch{ return false }
                
            }
            else{
                return saveNewObjectForName(entityName: name, withValues: values)
            }
        }
        catch{
            return false
        }
        return true
        
    }
    
    
    func retrieveSingleObject(forEntityName name:String) -> AnyObject?{
        let request = NSFetchRequest(entityName: name)
        request.returnsObjectsAsFaults = false
        let context:NSManagedObjectContext = appDel.managedObjectContext
        
        do{
            let results = try context.executeFetchRequest(request)
            if results.count == 1{
                let object = results[0]
                return object
            }
            else{
                return nil
            }
        }
        catch{
            return nil
        }
        
    }

}
