//
//  PJourneyMO+CoreDataProperties.swift
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

extension PJourneyMO {

    @NSManaged var name: String?
    @NSManaged var stations: NSSet?

}
