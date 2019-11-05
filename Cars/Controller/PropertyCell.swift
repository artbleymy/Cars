//
//  PropertyCell.swift
//  Cars
//
//  Created by Stanislav on 07/10/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//

import UIKit

final class PropertyCell: UITableViewCell
{
	let picker = UIPickerView()
	var pickerValues = [String]()
	var propertyNameLabel = UILabel()
	var propertyValueField = UITextField()

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLabel()
		setupValueField()

		picker.delegate = self
		picker.dataSource = self
	}

	@available(*, unavailable) required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	//Set up picker for cell if needed
	//if field is not empty - select appropriate value in picker
	func setUpPickerForCurrentCell(with values: [String]) {
		pickerValues = values
		propertyValueField.inputView = picker
		guard let text = propertyValueField.text else { return }
		if text.isEmpty == false {
			guard let index = pickerValues.firstIndex(of: text) else { return }
			picker.selectRow(index, inComponent: 0, animated: true)
		}
	}
	private func setupLabel() {
		propertyNameLabel.font = UIFont.systemFont(ofSize: 10)
		propertyNameLabel.text = "Test label"
		propertyNameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(propertyNameLabel)
		let margins = self.layoutMarginsGuide
		propertyNameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		propertyNameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		propertyNameLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
		propertyNameLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
	}
	private func setupValueField() {
		propertyValueField.font = UIFont.systemFont(ofSize: 14)
		propertyValueField.borderStyle = UITextField.BorderStyle.roundedRect
		propertyValueField.clearButtonMode = UITextField.ViewMode.whileEditing
		propertyValueField.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(propertyValueField)
		propertyValueField.delegate = self
		let margins = self.layoutMarginsGuide
		propertyValueField.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		propertyValueField.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		propertyValueField.heightAnchor.constraint(equalToConstant: 34).isActive = true
		propertyValueField.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
	}
}
// MARK: - Text field delegate methods
extension PropertyCell: UITextFieldDelegate
{
	//Dismiss red border on field while change focus
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField.layer.borderColor == UIColor.red.cgColor {
			textField.markFieldAsValid()
		}
	}
}
// MARK: - UIPickerView delegate and data source methods
extension PropertyCell: UIPickerViewDelegate, UIPickerViewDataSource
{
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerValues.count
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		propertyValueField.text = pickerValues[row]
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerValues[row]
	}
}
//Extend UITextField to change border if value is invalid
extension UITextField
{
	//Make border of property field red and set focus on it
	func markFieldAsInvalid() {
		self.layer.cornerRadius = 8.0
		self.layer.masksToBounds = true
		self.layer.borderWidth = 1
		self.layer.borderColor = UIColor.red.cgColor
		self.becomeFirstResponder()
	}
	//Reset border of field
	func markFieldAsValid() {
		self.layer.borderColor = UIColor.clear.cgColor
	}
}
