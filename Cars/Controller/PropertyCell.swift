//
//  PropertyCell.swift
//  Cars
//
//  Created by Stanislav on 07/10/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//

import UIKit

class PropertyCell: UITableViewCell {

    @IBOutlet weak var propertyNameLabel: UILabel!
    @IBOutlet weak var propertyValueField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
