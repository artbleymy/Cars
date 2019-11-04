//
//  CoreDataManager.swift
//  Cars
//
//  Created by Stanislav on 07/10/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//
// Class for managing of Core Data
// swiftlint:disable force_cast
import UIKit
import CoreData

final class CoreDataManager
{

	static let instance = CoreDataManager()
	let defaults = UserDefaults.standard
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	private init() {
		context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
		//Uncomment to reset counter of runs
		//        defaults.set(0, forKey: "numberOfRuns")

		//When application start first time, add some default values
		let numberOfRuns = defaults.integer(forKey: "numberOfRuns")
		if numberOfRuns == 0 {
			initDefaultRecords()
			saveContext()
		}
		defaults.set(numberOfRuns + 1, forKey: "numberOfRuns")
	}
	// MARK: - Data manipulation methods

	//Save context for Core Data
	func saveContext() {
		do {
			try context.save()
		} catch {
			print("Error while saving context\(error)")
		}
	}

	//Load cars from database and return array of Car
	func loadCars(with request: NSFetchRequest<Car> = Car.fetchRequest()) -> [Car]? {
		var carList: [Car]?
		request.sortDescriptors = [
			NSSortDescriptor(key: "name",
							 ascending: true,
							 selector: #selector(NSString.caseInsensitiveCompare))
		]
		do {
			carList = try context.fetch(request)
		} catch {
			print("Error while loading cars\(error)")
		}
		return carList
	}

	//Load properties list from database and return array of Property
	func loadProperties(with request: NSFetchRequest<Property> = Property.fetchRequest()) -> [Property]? {
		var propertiesList: [Property]?
		request.sortDescriptors = [NSSortDescriptor(key: "rating", ascending: true)]
		do {
			propertiesList = try context.fetch(request)
		} catch {
			print("Error while loading \(error)")
		}
		return propertiesList
	}

	//Load values of properties for car and return array of Value
	func loadValues(for car: Car) -> [Value]? {
		var valuesList: [Value]?
		let request: NSFetchRequest<Value> = Value.fetchRequest()
		let carPredicate = NSPredicate(format: "parentCar == %@", car)
		request.predicate = carPredicate
		do {
			valuesList = try context.fetch(request)
		} catch {
			print("Error while loading \(error)")
		}
		return valuesList
	}

	//Clear entity according predicate, if predicate is nil - delete all records
	func clearEntity(in entity: String, predicate: NSPredicate? = nil) {

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

	//Create new car with new name
	func createNewCar(with name: String) -> Car {
		let car = Car(context: context)
		car.name = name
		return car
	}
	// Delete car from context
	func deleteCarFromContext(car: Car) {
		context.delete(car)
		saveContext()
	}

	//Delete values of properties for current car
	func deleteValuesFromContext(values: [Value]) {
		for object in values {
			context.delete(object)
		}
		saveContext()
	}

	// MARK: - Append methods
	//Add car with name to source array
	private func appendToCarList(source array: [Car], name: String) -> [Car] {
		var carArray = array
		let car = Car(context: context)
		car.name = name
		carArray.append(car)
		return carArray
	}

	private func appendToPropertyList(source array: [Property],
									  incoming values: (name: String, descr: String, rating: Int, type: String, nullable: Bool)) -> [Property] {
		var propertyArray = array
		let property = Property(context: context)
		property.name = values.name
		property.descr = values.descr
		property.rating = Int16(values.rating)
		property.type = values.type
		property.nullable = values.nullable
		propertyArray.append(property)
		return propertyArray
	}

	func appendToValueList(source array: [Value], value: String, parentProperty: Property, parentCar: Car) -> [Value] {
		var valueArray = array
		let valueItem = Value(context: context)
		valueItem.value = value
		valueItem.parentProperty = parentProperty
		valueItem.parentCar = parentCar
		valueArray.append(valueItem)
		return valueArray
	}

	//Insert default records
	private func initDefaultRecords() {
		clearEntity(in: "Car")
		clearEntity(in: "Property")
		clearEntity(in: "Value")

		var propertiesList = [Property]()
		var propertyValues: (name: String, descr: String, rating: Int, type: String, nullable: Bool)

		propertyValues = (name: "Make", descr: "Производитель", rating: 1, type: "String", nullable: false)
		propertiesList = appendToPropertyList(source: propertiesList,
											  incoming: propertyValues)

		propertyValues = (name: "Model", descr: "Модель", rating: 2, type: "String", nullable: false)
		propertiesList = appendToPropertyList(source: propertiesList,
											  incoming: propertyValues)

		propertyValues = (name: "Type", descr: "Тип кузова", rating: 3, type: "String", nullable: true)
		propertiesList = appendToPropertyList(source: propertiesList,
											  incoming: propertyValues)

		propertyValues = (name: "Year", descr: "Год выпуска", rating: 4, type: "String", nullable: true)
		propertiesList = appendToPropertyList(source: propertiesList,
											  incoming: propertyValues)

		var carList = [Car]()
		carList = appendToCarList(source: carList, name: "BMW X5 2005 г.в.")
		carList = appendToCarList(source: carList, name: "Volkswagen Polo 2000 г.в.")
		carList = appendToCarList(source: carList, name: "Skoda Octavia")

		var valueList = [Value]()
		valueList = appendToValueList(source: valueList, value: "BMW",
									  parentProperty: propertiesList[0], parentCar: carList[0])
		valueList = appendToValueList(source: valueList, value: "X5",
									  parentProperty: propertiesList[1], parentCar: carList[0])
		valueList = appendToValueList(source: valueList, value: "Volkswagen",
									  parentProperty: propertiesList[0], parentCar: carList[1])
		valueList = appendToValueList(source: valueList, value: "Polo",
									  parentProperty: propertiesList[1], parentCar: carList[1])
		valueList = appendToValueList(source: valueList, value: "2000",
									  parentProperty: propertiesList[3], parentCar: carList[1])
		valueList = appendToValueList(source: valueList, value: "Skoda",
									  parentProperty: propertiesList[0], parentCar: carList[2])
		valueList = appendToValueList(source: valueList, value: "Octavia",
									  parentProperty: propertiesList[1], parentCar: carList[2])
		valueList = appendToValueList(source: valueList, value: "Sedan",
									  parentProperty: propertiesList[2], parentCar: carList[2])
		saveContext()
	}
}
