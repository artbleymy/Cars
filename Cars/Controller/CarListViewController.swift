//
//  CarListViewController.swift
//  Cars
//
//  Created by Stanislav on 07/10/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//

import UIKit

class CarListViewController: UIViewController {

    let coreDataManager = CoreDataManager.instance
    var carList = [Car]()
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var carTableView: UITableView!
    
    
    
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
//MARK: - Table View delegate and data source methods
extension CarListViewController: UITableViewDelegate, UITableViewDataSource {
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
        carTableView.deselectRow(at: indexPath, animated: true)
    }
    
    //swipe left to delete car
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delete car
            let alert = UIAlertController(title: "Внимание", message: "Вы точно хотите удалить автомобиль?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
                let car = self.carList[indexPath.row]
                if let carName = car.name {
                    let predicate = NSPredicate(format: "name MATCHES %@", carName)
                    self.coreDataManager.clearEntity(in: "Car", predicate: predicate)
                    self.carList.removeAll(where: {$0 == car})
                    self.carTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            //show alert with questtion
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    
    
    
}

