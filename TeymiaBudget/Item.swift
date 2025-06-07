//
//  Item.swift
//  TeymiaBudget
//
//  Created by Aman on 7/6/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
