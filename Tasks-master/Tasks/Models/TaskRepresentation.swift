//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by Ben Gohlke on 2/26/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable {
    var name: String
    var notes: String?
    var priority: String
    var identifier: String?
    var completed: Bool?
}
