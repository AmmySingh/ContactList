//
//  GroupBy+CoreDataProperties.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/15/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import Foundation
import CoreData


extension GroupBy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupBy> {
        return NSFetchRequest<GroupBy>(entityName: "GroupBy");
    }

    @NSManaged public var groupName: String?
    @NSManaged public var groupImage: NSData?
    @NSManaged public var contactsCount: Int32
    @NSManaged public var contactRelationShip: NSSet?

}

// MARK: Generated accessors for contactRelationShip
extension GroupBy {

    @objc(addContactRelationShipObject:)
    @NSManaged public func addToContactRelationShip(_ value: ContactUser)

    @objc(removeContactRelationShipObject:)
    @NSManaged public func removeFromContactRelationShip(_ value: ContactUser)

    @objc(addContactRelationShip:)
    @NSManaged public func addToContactRelationShip(_ values: NSSet)

    @objc(removeContactRelationShip:)
    @NSManaged public func removeFromContactRelationShip(_ values: NSSet)

}
