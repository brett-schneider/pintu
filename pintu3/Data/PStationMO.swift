//
//  PStationMO.swift
//  pintu3
//
//  Created by Brett on 28/10/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import CoreData

class PStationMO: NSManagedObject {
    @NSManaged var addedBy: String
    @NSManaged var addedByID: String
    @NSManaged var addedDate: NSDate
    @NSManaged var image: NSData
    @NSManaged var price: NSNumber
    @NSManaged var rating: NSNumber
    @NSManaged var text: String
    
    @NSManaged var location: NSManagedObject
    @NSManaged var journeys: NSSet
    
    func addJourney(journey: NSManagedObject) {
        let alteredJourneys = journeys.mutableCopy()
        alteredJourneys.addObject(journey)
    }
    
}
