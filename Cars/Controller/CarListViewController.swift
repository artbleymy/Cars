//
//  CarListViewController.swift
//  Cars
//
//  Created by Stanislav on 07/10/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//
// swiftlint:disable prohibited_interface_builder
import UIKit

final class CarListViewController: UIViewController, PropertyEditDelegate
{

	// MARK: - Vars
	let coreDataManager = CoreDataManager.instance
	var carList = [Car]()
	// MARK: - IBOutlets
	@IBOutlet weak var carTableView: UITableView!
	// MARK: - IBActions
	//add new car
	@IBAction func addPressed(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: "goToProperties", sender: self)
	}
	// MARK: - List of cars support methods
	override func viewDidLoad() {
		super.viewDidLoad()
		print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
		carTableView.delegate = self
		carTableView.dataSource = self
		carTableView.tableFooterView = UIView()
		//carList = ["BMW", "Skoda", "Volkswagen"]

		refreshCarList()
	}

	//Refresh carList from database
	func refreshCarList() {

		if let array = coreDataManager.loadCars() {
			carList = array
		}
		carTableView.reloadData()
	}
}
// MARK: - Table View delegate and data source methods
extension CarListViewController: UITableViewDelegate, UITableViewDataSource
{
	//return number of cars
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return carList.count
	}

	//return filled cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = carTableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath)
		cell.textLabel?.text = carList[indexPath.row].name
		return cell
	}

	//action when select row
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		performSegue(withIdentifier: "goToProperties", sender: self)
		carTableView.deselectRow(at: indexPath, animated: true)
	}

	//swipe left to delete car
	func tableView(_ tableView: UITableView,
				   commit editingStyle: UITableViewCell.EditingStyle,
				   forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let alert = UIAlertController(title: "Внимание",
										  message: "Удалить \(carList[indexPath.row].name ?? "")?",
				preferredStyle: .alert)

			let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

			let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
				//delete car
				self.coreDataManager.deleteCarFromContext(car: self.carList[indexPath.row])
				self.carList.remove(at: indexPath.row)
				self.carTableView.deleteRows(at: [indexPath], with: .automatic)
			}
			alert.addAction(cancelAction)
			alert.addAction(deleteAction)
			//show alert with questtion
			present(alert, animated: true, completion: nil)
		}
	}
	//when go to properties
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "goToProperties"{
			guard let propertyViewController = segue.destination as? PropertyViewController else { return }
			propertyViewController.delegate = self
			if let indexPath = carTableView.indexPathForSelectedRow {
				propertyViewController.selectedCar = carList[indexPath.row]
			}
		}
	}
}
