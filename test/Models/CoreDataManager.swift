//
//  CoreDataManager.swift
//  test
//
//  Created by Yurij on 11.07.2021.
//

import Foundation
import CoreData

class CoreDataManager {
    private let modelName: String
    
    init(modelName: String){
        self.modelName = modelName
    }
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "mmomd") else {
            return nil
        }
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        return managedObjectModel
    }()
}
