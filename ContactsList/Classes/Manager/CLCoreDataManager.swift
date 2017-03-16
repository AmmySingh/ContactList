//
//  CLCoreDataManager.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/11/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import UIKit
import CoreData

class CLCoreDataManager: NSObject {
    
    class func saveContact(contactObject: NSManagedObject?, fName: String?, lName: String?, pNumber: String?, userImage: Data?, completion: (_ status: Bool) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let predicate: NSPredicate?
        
        if contactObject != nil {
            predicate = NSPredicate(format: "SELF == %@", contactObject!)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA_ENTITY.CONTACT_USER)
            fetchRequest.predicate = predicate
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                if result.count > 0 {
                    
                    let contact: ContactUser = result[0] as! ContactUser
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    contact.firstName   = fName
                    contact.lastName    = lName
                    contact.phoneNumber = pNumber
                    contact.userImage   = userImage as NSData?
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return completion(false)
            }
        } else {
            let contact: ContactUser = NSEntityDescription.insertNewObject(forEntityName: COREDATA_ENTITY.CONTACT_USER, into: managedContext) as! ContactUser
            contact.firstName   = fName
            contact.lastName    = lName
            contact.phoneNumber = pNumber
            contact.userImage   = userImage as NSData?
        }
        
        do {
            try managedContext.save()
            completion(true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            completion(false)
        }
    }
    
    class func saveGroup(groupObject: NSManagedObject?, contactsSet: NSSet, groupName: String, groupIcon: Data?, completion: (_ status: Bool) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let predicate: NSPredicate?
        
        if groupObject != nil {
            predicate = NSPredicate(format: "SELF == %@", groupObject!)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA_ENTITY.GROUP_BY)
            fetchRequest.predicate = predicate
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                if result.count > 0 {
                    
                    let group: GroupBy = result[0] as! GroupBy
                    group.removeFromContactRelationShip(group.contactRelationShip!)
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    group.groupName  = groupName
                    group.groupImage = groupIcon as NSData?
                    group.contactsCount = Int32(contactsSet.count)
                    group.addToContactRelationShip(contactsSet)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return completion(false)
            }
        } else {
            
            let group: GroupBy = NSEntityDescription.insertNewObject(forEntityName: COREDATA_ENTITY.GROUP_BY, into: managedContext) as! GroupBy
            group.groupName  = groupName
            group.groupImage = groupIcon as NSData?
            group.contactsCount = Int32(contactsSet.count)
            group.addToContactRelationShip(contactsSet)
        }
        
        do {
            try managedContext.save()
            completion(true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            completion(false)
        }
    }
    
    class func fetchContacts (completion: (_ result: [NSManagedObject], _ status: Bool) -> Void) {
        
        let object = [NSManagedObject]()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return completion(object, false)
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA_ENTITY.CONTACT_USER)
        
        do {
            let people = try managedContext.fetch(fetchRequest)
            return completion(people, true)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return completion(object, false)
        }
    }
    
    class func fetchContactsCount (completion: (_ count: Int) -> Void) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return completion(0)
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA_ENTITY.CONTACT_USER)
        
        do {
            let count = try managedContext.count(for: fetchRequest)
            return completion(count)
        } catch let error as NSError {
            print("Could not fetch count. \(error), \(error.userInfo)")
            return completion(0)
        }
    }
    
    class func fetchGroups (completion: (_ result: [NSManagedObject], _ status: Bool) -> Void) {
        
        let object = [NSManagedObject]()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return completion(object, false)
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA_ENTITY.GROUP_BY)
        
        do {
            let groups = try managedContext.fetch(fetchRequest)
            return completion(groups, true)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return completion(object, false)
        }
    }
    
    class func fetchContactsNotInGroup (groupObject: NSManagedObject?, completion: (_ result: [NSManagedObject], _ status: Bool) -> Void) {
        
        let object = [NSManagedObject]()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return completion(object, false)
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let predicate: NSPredicate?
        
        if groupObject != nil {
            predicate = NSPredicate(format: "groupRelationship == %@ OR groupRelationship == %@", NSNull(), groupObject!)
        } else {
            predicate = NSPredicate(format: "groupRelationship == %@", NSNull())
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA_ENTITY.CONTACT_USER)
        fetchRequest.predicate = predicate
        
        do {
            let people = try managedContext.fetch(fetchRequest)
            return completion(people, true)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return completion(object, false)
        }
    }
    
    class func checkIfOtherContactsContainInGroup(object: NSManagedObject, completion: (_ status: Bool) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let predicate = NSPredicate(format: "groupRelationship == %@", object)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA_ENTITY.CONTACT_USER)
        fetchRequest.predicate = predicate
        
        do {
            let people = try managedContext.fetch(fetchRequest)
            return completion(people.count > 0 ? true:false)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return completion(false)
        }
    }
    
    class func delete(object: NSManagedObject, completion: (_ status: Bool) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            managedContext.delete(object)
            try managedContext.save()
            return completion(true)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return completion(false)
        }
    }
}
