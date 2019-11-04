//
//  PropertyViewController.swift
//  Cars
//
//  Created by Stanislav on 07/10/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//
// swiftlint:disable prohibited_interface_builder

import UIKit

protocol PropertyEditDelegate: AnyObject
{
	func refreshCarList()
}

final class PropertyViewController: UIViewController
{
	// MARK: - Properties
	let coreDataManager = CoreDataManager.instance
	weak var delegate: PropertyEditDelegate?
	var selectedCar: Car? {
		didSet {
			loadValuesOfSelectedCar()
		}
	}
	var possibleYearsList = [String]()
	var propertiesList = [Property]()
	var valuesList = [Value]()
	//IBOutlets
	@IBOutlet weak var propertyTableView: UITableView!
	//IBActions
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		saveProperties()
	}
	// MARK: - viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		propertyTableView.delegate = self
		propertyTableView.dataSource = self
		propertyTableView.tableFooterView = UIView()
		propertyTableView.separatorStyle = .none
		//tap anywhere to hide keyboard
		let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
		view.addGestureRecognizer(tap)
		//load properties from database
		if let propertyArray = coreDataManager.loadProperties() {
			propertiesList = propertyArray
		}
		setPossibleYears()
	}
	// MARK: - Edit properties support
	private func generateNewNameCar() -> String {
		var template = ""
		for index in 0..<propertiesList.count {
			guard let cell = propertyTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PropertyCell
				else { return "" }
			if let value = cell.propertyValueField.text {
				switch propertiesList[index].name {
				case "Make":
					template += value
				case "Model":
					template += value.isEmpty ? "" : (" " + value)
				case "Year":
					template += value.isEmpty ? "" : (" " + value + " г.в.")
				default:
					template += ""
				}
			}
		}
		return template
	}
	//Return current value of property for selected car
	private func getValueForProperty(property: Property) -> String? {
		let filteredValues = valuesList.filter{ $0.parentProperty == property }
		return (filteredValues.count > 0) ? filteredValues[0].value : nil
	}
	//load values for selectedCar
	private func loadValuesOfSelectedCar() {
		guard let car = selectedCar else { return }
		if let valuesArray = coreDataManager.loadValues(for: car) {
			valuesList = valuesArray
		}
	}
	//Save properies for current car, if new car - create car before saving
	private func saveProperties() {
		guard validation() else { return }
		var valuesListForSave = [Value]()
		var car: Car
		let newName = generateNewNameCar()
		if let existingCar = selectedCar {
			car = existingCar
			car.name = newName
			coreDataManager.deleteValuesFromContext(values: valuesList)
		} else {
			car = coreDataManager.createNewCar(with: newName)
		}
		//insert properties
		for index in 0..<propertiesList.count {
			guard let cell = propertyTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PropertyCell else { return }
			if let value = cell.propertyValueField.text {
				valuesListForSave = coreDataManager.appendToValueList(source: valuesListForSave,
																	  value: value,
																	  parentProperty: propertiesList[index],
																	  parentCar: car)
			}
		}
		coreDataManager.saveContext()
		self.navigationController?.popViewController(animated: true)
		delegate?.refreshCarList()
	}
	//Validate values
	//return true if ok, false - if fields not valid
	private func validation() -> Bool {
		for index in 0..<propertiesList.count where propertiesList[index].nullable == false {
			//Check not nullable fields
			guard let cell = propertyTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PropertyCell
				else { return false }
			if let value = cell.propertyValueField.text, value.isEmpty {
				//print("Не заполнено обязательное поле \(propertiesList[index].descr)")
				cell.propertyValueField.markFieldAsInvalid()
				return false
			}
		}
		return true
	}
	//Make array of possible years
	private func setPossibleYears() {
		let calendar = Calendar.current
		let currentYear = calendar.component(.year, from: Date())
		for year in (currentYear - 100...currentYear).reversed() {
			possibleYearsList.append(String(year))
		}
	}
}
// MARK: - Table View delegate and data source methods
extension PropertyViewController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return propertiesList.count
	}
	//setting up cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = propertyTableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath)
		if let propertyCell = cell as? PropertyCell {
			//set property name for cell
			let property = propertiesList[indexPath.row]
			propertyCell.propertyNameLabel.text = property.descr
			propertyCell.propertyValueField.placeholder = property.descr
			//set value of property for cell
			if let value = getValueForProperty(property: property) {
				propertyCell.propertyValueField.text = value
			}
			//different input methods for different type of properties
			if property.type == "Year" {
				propertyCell.setUpPickerForCurrentCell(with: possibleYearsList)
			}
		}
		return cell
	}
}
