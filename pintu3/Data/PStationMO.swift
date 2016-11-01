//
//  PStationMO.swift
//  pintu3
//
//  Created by Brett on 01/11/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import Foundation
import CoreData

@objc(PStationMO)
class PStationMO: NSManagedObject {

    func addJourney(journey: PJourneyMO) {
        self.mutableSetValueForKey("journeys").addObject(journey)
        /*
        let alteredJourneys = journeys!.mutableCopy()
        alteredJourneys.addObject(journey)
        */
    }

}
