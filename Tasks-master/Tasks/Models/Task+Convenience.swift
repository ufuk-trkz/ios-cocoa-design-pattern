//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Ben Gohlke on 2/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: String, CaseIterable {
    case low
    case normal
    case high
    case critical
}

extension Task {
    
    // This computed property allows any managed object to become a TaskRepresentation for sending to Firebase
    var taskRepresentation: TaskRepresentation? {
        guard let name = name,
            let priority = priority else {
                return nil
        }
        
        return TaskRepresentation(name: name, notes: notes, priority: priority, identifier: identifier?.uuidString, completed: completed)
    }
    
    // This creates a new managed object from raw data
    @discardableResult convenience init(name: String,
                     notes: String? = nil,
                     priority: TaskPriority = .normal,
                     completed: Bool = false,
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.notes = notes
        self.priority = priority.rawValue
        self.completed = completed
        self.identifier = identifier
    }
    
    // This creates a managed object from a TaskRepresentation object (which comes from Firebase)
    @discardableResult convenience init?(taskRepresentation: TaskRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let priority = TaskPriority(rawValue: taskRepresentation.priority),
            let identifierString = taskRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString) else {
                return nil
        }
        
        self.init(name: taskRepresentation.name,
                  notes: taskRepresentation.notes,
                  priority: priority,
                  completed: taskRepresentation.completed ?? false,
                  identifier: identifier,
                  context: context)
    }
}
