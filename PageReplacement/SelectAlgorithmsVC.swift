//
//  SelectAlgorithmsVC.swift
//  PageReplacement
//
//  Created by Weslie on 2018/12/29.
//  Copyright © 2018 Weslie. All rights reserved.
//

import UIKit

class SelectAlgorithmsVC: UITableViewController {
	
	var segue: UIStoryboardSegue?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var type: AlgorithmType = .FIFO
		switch indexPath.row {
		case 0: type = .FIFO
		case 1: type = .LRU
		case 2: type = .OPT
		default: break
		}
		if segue?.identifier == "algorithm" {
			let source = segue?.source as! ViewController
			source.algorithmType = type
			source.navigationItem.title = type.rawValue
		}
		
		self.navigationController?.popViewController(animated: true)
	}
}
