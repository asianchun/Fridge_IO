//
//  GroceryListTableViewCell.swift
//  Fridge_IO
//
//  Created by Hong Yi on 23/5/2023.
//

import UIKit

class GroceryListTableViewCell: UITableViewCell {

    @IBOutlet weak var listTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
