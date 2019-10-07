//
//  CoreDataManager.swift
//  Cars
//
//  Created by Stanislav on 07/10/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//
// Class for managing of Core Data

import UIKit
import CoreData

class CoreDataManager {
    
    static let instance = CoreDataManager()
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() {
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        defaults.set(0, forKey: "numberOfRuns")
        let numberOfRuns = defaults.integer(forKey: "numberOfRuns")
        //When application start first time, add some default values
        if numberOfRuns == 0 {
            initDefaultValues()
            saveContext()
        }
        defaults.set(numberOfRuns + 1, forKey: "numberOfRuns")
    }
//MARK: - Data manipulation methods
    
    //Save context for Core Data
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error while saving context\(error)")
        }
    }
    
    //Load cars from database and return array of Car
    func loadCars(with request: NSFetchRequest<Car> = Car.fetchRequest()) -> [Car]? {
        var carList: [Car]?
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            carList = try context.fetch(request)
        } catch {
            print("Error while loading cars\(error)")
        }
        return carList
    }
    
    //Clear entity according predicate, if predicate is nil - delete all records
    func clearEntity(in entity: String, predicate: NSPredicate? = nil){
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if let addPredicate = predicate {
            deleteFetch.predicate = addPredicate
        }
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error while cleaning entity \(entity)")
        }
    }
    //MARK: - Append methods
    //Add car with name to source array
    private func appendToCarList(source array: [Car], name: String) -> [Car]{
        var carArray = array
        let car = Car(context: context)
        car.name = name
        carArray.append(car)
        return carArray
    }
    
    //Fill default values
    private func initDefaultValues() {
        clearEntity(in: "Car")
        var carList = [Car]()
        carList = appendToCarList(source: carList, name: "BMW X5 2005 г.в.")
        carList = appendToCarList(source: carList, name: "Volkswagen Polo 2000 г.в.")
        carList = appendToCarList(source: carList, name: "Skoda Octavia 2010 г.в.")
        
        saveContext()
    }
    
    
    
}
