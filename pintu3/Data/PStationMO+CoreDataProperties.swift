//
//  PStationMO+CoreDataProperties.swift
//  pintu3
//
//  Created by Brett on 01/11/16.
//  Copyright © 2016 Brett. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PStationMO {

    @NSManaged var addedBy: String?
    @NSManaged var addedByID: String?
    @NSManaged var addedDate: NSDate?
    @NSManaged var image: NSData?
    @NSManaged var price: NSNumber?
    @NSManaged var rating: NSNumber?
    @NSManaged var text: String?
    @NSManaged var name: String?
    @NSManaged var journeys: NSSet?
    @NSManaged var location: PLocationMO?

}
