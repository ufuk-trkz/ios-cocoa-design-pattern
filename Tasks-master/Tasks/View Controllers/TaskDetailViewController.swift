//
//  TaskDetailViewController.swift
//  Tasks
//
//  Created by Ben Gohlke on 2/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var priorityControl: UISegmentedControl!
    @IBOutlet var completedButton: UIButton!
    
    // MARK: - Properties
    
    // This is a managed object from the Core Data model
    var task: Task?
    var taskController: TaskController?
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.text = ""
        let priority: TaskPriority
        if let taskPriority = task?.priority {
            priority = TaskPriority(rawValue: taskPriority)!
        } else {
            priority = .normal
        }
        priorityControl.selectedSegmentIndex = TaskPriority.allCases.firstIndex(of: priority) ?? 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let task = task {
            title = task.name
            nameTextField.text = task.name
            notesTextView.text = task.notes
            let priority: TaskPriority
            if let taskPriority = task.priority {
                priority = TaskPriority(rawValue: taskPriority)!
            } else {
                priority = .normal
            }
            priorityControl.selectedSegmentIndex = TaskPriority.allCases.firstIndex(of: priority) ?? 1
            completedButton.setImage(task.completed ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
        } else {
            // If no task was passed in, assume the user wants to create one,
            // so add a button to the navbar to "save" the new task
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let task = task {
            guard let name = nameTextField.text,
                !name.isEmpty else { return }
            
            let notes = notesTextView.text
            
            let priorityIndex = priorityControl.selectedSegmentIndex
            let priority = TaskPriority.allCases[priorityIndex]
            
            task.name = name
            task.notes = notes
            task.priority = priority.rawValue
            
            do {
                try CoreDataStack.shared.save()
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
            taskController?.sendTaskToServer(task: task)
        }
    }
    
    // MARK: - Actions
    
    @objc func save() {
        guard let name = nameTextField.text,
            !name.isEmpty else { return }
        
        let notes = notesTextView.text
        
        let priorityIndex = priorityControl.selectedSegmentIndex
        let priority = TaskPriority.allCases[priorityIndex]
        
        let task = Task(name: name, notes: notes, priority: priority)
        saveTask()
        taskController?.sendTaskToServer(task: task)
        navigationController?.dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: .taskSaved, object: self)
    }
    
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
    
    private func saveTask() {
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    
        guard let task = task else { return }
        let taskData = try? PropertyListEncoder().encode(task.taskRepresentation)
        coder.encode(taskData, forKey: "taskDataKey")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        guard let taskData = coder.decodeObject(forKey: "taskDataKey") as? Data, let taskRep = try? PropertyListDecoder().decode(TaskRepresentation.self, from: taskData) else { return }
        task = Task(taskRepresentation: taskRep)
        
    }
}

