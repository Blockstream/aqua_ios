//
//  AssetInfoCellController.swift
//  aquaios
//
//  Created by Domenico Gabriele on 20/07/2020.
//  Copyright © 2020 Blockstream. All rights reserved.
//

import Foundation
import UIKit

class AssetInfoCell: UITableViewCell {

    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoText: UILabel!

    func setup(title: String, text: String) {
        backgroundColor = .aquaBackgroundBlue
        infoTitle.text = title
        infoText.text = text
    }

    func setup(title: String) {
        backgroundColor = .aquaBackgroundBlue
        infoTitle.text = title
        infoText.text = ""
        infoTitle.textColor = .paleLilac
    }
}
