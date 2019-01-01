//
//  InputViewController.swift
//  PageReplacement
//
//  Created by Weslie on 2018/12/29.
//  Copyright © 2018 Weslie. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {
	
	var segue: UIStoryboardSegue?

	var inputNums: [Int]!
	@IBOutlet weak var inputTF: UITextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        self.inputTF.becomeFirstResponder()
		
		var text = ""
		for num in inputNums {
			text += "\(num) "
		}
    }
	
}

extension InputViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
}
