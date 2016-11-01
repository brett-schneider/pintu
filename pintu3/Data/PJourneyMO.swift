//
//  PJourneyMO.swift
//  pintu3
//
//  Created by Brett on 01/11/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import Foundation
import CoreData

@objc(PJourneyMO)
class PJourneyMO: NSManagedObject {

    func addStation(station: PStationMO) {
        /*
        let alteredJourneys = stations!.mutableCopy()
        alteredJourneys.addObject(station)
        */
        self.mutableSetValueForKey("stations").addObject(station)
    }

}
