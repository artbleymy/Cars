//
//  PropertyCell.swift
//  Cars
//
//  Created by Stanislav on 07/10/2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//

import UIKit

class PropertyCell: UITableViewCell {

    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var propertyTextField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
