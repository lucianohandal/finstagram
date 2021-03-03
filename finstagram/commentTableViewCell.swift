//
//  commentTableViewCell.swift
//  finstagram
//
//  Created by Luciano Handal on 3/1/21.
//

import UIKit

class commentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var commentAuthor: UILabel!
    @IBOutlet weak var commentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
