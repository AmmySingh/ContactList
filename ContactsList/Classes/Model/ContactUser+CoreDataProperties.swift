//
//  ContactUser+CoreDataProperties.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/15/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import Foundation
import CoreData


extension ContactUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactUser> {
        return NSFetchRequest<ContactUser>(entityName: "ContactUser");
    }

    @NSManaged public var firstName: String?
    @NSManaged public var groupId: Int32
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var userImage: NSData?
    @NSManaged public var groupRelationship: GroupBy?

}
