//
//  TaskCell.swift
//  Tasks
//
//  Created by Ben Gohlke on 2/25/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    // MARK: - Properties
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var completedButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func toggleComplete(_ sender: UIButton) {
        // This changes it from true to false or vice versa
        task?.completed.toggle()
        
        guard let task = task else { return }
        
        // Sets the button image to the correct SF Symbol (either checked or empty)
        completedButton.setImage(task.completed ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)

        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    // MARK: - Private
    
    private func updateViews() {
        guard let task = task else { return }
        
        taskTitleLabel.text = task.name
        completedButton.setImage(task.completed ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }
}
