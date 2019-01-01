//
//  ViewController.swift
//  PageReplacement
//
//  Created by Weslie on 2018/12/29.
//  Copyright © 2018 Weslie. All rights reserved.
//

import UIKit

enum AlgorithmType: String {
	case FIFO = "FIFO"
	case LRU = "LRU"
	case OPT = "OPT"
}

class ViewController: UIViewController {
	
	var testArray = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1] {
		didSet {
			pageCount = testArray.count
			// refresh ui
			refresh()
			stackView.subviews.forEach { $0.removeFromSuperview() }
			for num in testArray {
				let label = UILabel()
				label.textAlignment = .center
				label.text = String(num)
				label.frame.size.height = stackView.frame.height
				stackView.addArrangedSubview(label)
			}
			// perform algorithm
			switch algorithmType {
			case .FIFO: table = performFIFO(target: testArray)
			case .LRU:  table = performLRU(target: testArray)
			case .OPT: table = performOPT(target: testArray)
			}
		}
	}
	
	let blockCount = 3
	var lackCount = 0
	var pageCount = 0
	var algorithmType: AlgorithmType = .FIFO {
		didSet {
			// reset
			refresh()
			switch algorithmType {
			case .FIFO: table = performFIFO(target: testArray)
			case .LRU:  table = performLRU(target: testArray)
			case .OPT: table = performOPT(target: testArray)
			}
		}
	}
	var timer = Timer()
	var table = [[Int]]() {
		didSet {
			collectionView.reloadData()
		}
	}
	var notLackIndex = [Int]()
	var animateLblCount = -1 {
		didSet {
			if animateLblCount > testArray.count - 1 {
				// animation end
				timer.invalidate()
				isPlaying = false
				stackView.arrangedSubviews.forEach { ($0 as! UILabel).backgroundColor = UIColor.white }
				// calculate
				let per: Double = Double(lackCount) / Double(testArray.count)
				let percentageStr = numberAsPercentage(per)
				lackRateLbl.text = "Lack Rate: \(percentageStr)%"
				lackCountLbl.text = "Lack Page Count: \(lackCount)"
				collectionView.reloadData()
				return
			}
			if animateLblCount == -1 {
				return
			}
			startAnimation()
			
		}
	}
	
	var isPlaying = false {
		didSet {
			if isPlaying {
				let button = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pause))
				navigationItem.rightBarButtonItem = button
			} else {
				let button = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(play))
				navigationItem.rightBarButtonItem = button
			}
		}
	}
	
	@IBOutlet weak var lackCountLbl: UILabel!
	@IBOutlet weak var lackRateLbl: UILabel!
	@IBOutlet weak var totalPageLbl: UILabel! {
		didSet {
			totalPageLbl.text = "Total Page: \(testArray.count)"
		}
	}
	@IBOutlet weak var pageStepper: UIStepper!
	
	@IBOutlet weak var stackView: UIStackView! {
		didSet {
			for num in testArray {
				let label = UILabel()
				label.textAlignment = .center
				label.text = String(num)
				label.frame.size.height = stackView.frame.height
				stackView.addArrangedSubview(label)
			}
		}
	}
	@IBOutlet weak var collectionView: UICollectionView!
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		table = performLRU(target: testArray)
		
		// add swipe gesture
//		let swipe = UISwipeGestureRecognizer(target: self, action: #selector(generateRandomNumbers))
//		stackView.addGestureRecognizer(swipe)
	}
	
	@IBAction func playClicked(_ sender: UIBarButtonItem) {
		isPlaying = !isPlaying
		
		timer.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
			self.animateLblCount += 1
		})
	}
	
	@IBOutlet weak var stepper: UIStepper!
	@IBAction func changePage(_ sender: Any) {
		pageCount = Int(stepper.value)
		totalPageLbl.text = "Total Page: \(pageCount)"
	}
	
	@objc func play() {
		isPlaying = !isPlaying
		
		// timer
		timer.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
			self.animateLblCount += 1
		}
		
	}
	
	@IBAction func generateRandomNumbers(_ sender: Any) {
		var numbers = (1...pageCount).map { _ in Int(arc4random_uniform(9)) }
		// first three not equal
		modifyArray(&numbers)
		print(numbers)
		testArray = numbers
	}
	
	@objc func pause() {
		isPlaying = !isPlaying
		timer.invalidate()
	}
	
	// segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "algorithm" {
			let dest = segue.destination as! SelectAlgorithmsVC
			dest.segue = segue
		} else if segue.identifier == "input" {
			let dest = segue.destination as! InputViewController
			dest.inputNums = testArray
			dest.segue = segue
		}
	}

}

// MARK:- Algorithms Core
extension ViewController {
	func performFIFO(target array: [Int]) -> [[Int]] {
		var martix = [[Int]]()
		var counts = [3, 2, 1]
		var tempColumn = [0, 0, 0]
		
		// not lack
		var notLackCount = 0
		
		for i in stride(from: 0, to: array.count, by: 1) {
			if i == 0 {
				let firstColumn = [array[0], -1, -1]
				martix.append(firstColumn)
			} else if i == 1 {
				let secondColumn = [array[0], array[1], -1]
				martix.append(secondColumn)
			} else if i == 2 {
				let thirdColumn = [array[0], array[1], array[2]]
				martix.append(thirdColumn)
				tempColumn = thirdColumn
			} else {
				// core
				// calculate count appeared
				let targetNum = array[i]
				let targetIndex = counts.firstIndex(of: counts.max()!)!
				var someColumn = tempColumn
				
				// the column contains num
				if someColumn.contains(targetNum) {
					martix.append(someColumn)
					notLackCount += 1
					continue
				}
				
				// change column and append
				someColumn[targetIndex] = targetNum
				martix.append(someColumn)
				// update temp column
				tempColumn = someColumn
				
				// change counts array
				for j in stride(from: 0, to: 3, by: 1) {
					if j != targetIndex {
						counts[j] += 1
					}
				}
				counts[targetIndex] = 1
			}
		}
		
		// lack count
		lackCount = array.count - notLackCount
		return martix
	}
	
	func performLRU(target array: [Int]) -> [[Int]] {
		var martix = [[Int]]()
		var indexes = [3, 2, 1]
		var tempColumn = [0, 0, 0]
		
		// not lack
		var notLackCount = 0
		for i in stride(from: 0, to: array.count, by: 1) {
			if i == 0 {
				let firstColumn = [array[0], -1, -1]
				martix.append(firstColumn)
			} else if i == 1 {
				let secondColumn = [array[0], array[1], -1]
				martix.append(secondColumn)
			} else if i == 2 {
				let thirdColumn = [array[0], array[1], array[2]]
				martix.append(thirdColumn)
				tempColumn = thirdColumn
			} else {
				// core
				// update index
				let targetNum = array[i]
				indexes[0] = array[0...i].lastIndex(of: tempColumn[0])!
				indexes[1] = array[0...i].lastIndex(of: tempColumn[1])!
				indexes[2] = array[0...i].lastIndex(of: tempColumn[2])!
				
				let targetIndex = indexes.firstIndex(of: indexes.min()!)!
				
				var someColumn = tempColumn
				
				// the column contains num
				if someColumn.contains(targetNum) {
					martix.append(someColumn)
					notLackCount += 1
					continue
				}
				
				// change column and append
				someColumn[targetIndex] = targetNum
				martix.append(someColumn)
				// update temp column
				tempColumn = someColumn
				
				// update index
				indexes[0] = array[0...i].lastIndex(of: tempColumn[0])!
				indexes[1] = array[0...i].lastIndex(of: tempColumn[1])!
				indexes[2] = array[0...i].lastIndex(of: tempColumn[2])!
			}
		}
		
		// lack count
		lackCount = array.count - notLackCount
		return martix
	}
	
	func performOPT(target array: [Int]) -> [[Int]] {
		var martix = [[Int]]()
		var indexes = [3, 2, 1]
		var tempColumn = [0, 0, 0]
		
		// not lack
		var notLackCount = 0
		for i in stride(from: 0, to: array.count, by: 1) {
			if i == 0 {
				let firstColumn = [array[0], -1, -1]
				martix.append(firstColumn)
			} else if i == 1 {
				let secondColumn = [array[0], array[1], -1]
				martix.append(secondColumn)
			} else if i == 2 {
				let thirdColumn = [array[0], array[1], array[2]]
				martix.append(thirdColumn)
				tempColumn = thirdColumn
			} else {
				// core
				// update index
				let targetNum = array[i]
				indexes[0] = array[i..<array.count].firstIndex(of: tempColumn[0]) ?? Int.max
				indexes[1] = array[i..<array.count].firstIndex(of: tempColumn[1]) ?? Int.max
				indexes[2] = array[i..<array.count].firstIndex(of: tempColumn[2]) ?? Int.max
				
				let targetIndex = indexes.firstIndex(of: indexes.max()!)!
				
				var someColumn = tempColumn
				
				// the column contains num
				if someColumn.contains(targetNum) {
					martix.append(someColumn)
					notLackCount += 1
					continue
				}
				
				// change column and append
				someColumn[targetIndex] = targetNum
				martix.append(someColumn)
				// update temp column
				tempColumn = someColumn
				
				// update index
				indexes[0] = array[i..<array.count].firstIndex(of: tempColumn[0]) ?? Int.max
				indexes[1] = array[i..<array.count].firstIndex(of: tempColumn[1]) ?? Int.max
				indexes[2] = array[i..<array.count].firstIndex(of: tempColumn[2]) ?? Int.max
			}
		}
		
		// lack count
		lackCount = array.count - notLackCount
		return martix
	}
}

// MARK:- Aided functions {
extension ViewController {
	
	func numberAsPercentage(_ number: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.percentSymbol = ""
		formatter.roundingMode = .halfUp
		formatter.maximumFractionDigits = 1
		return formatter.string(from: NSNumber(value:number))!
	}
	
	func startAnimation() {
		stackView.arrangedSubviews.forEach { ($0 as! UILabel).backgroundColor = UIColor.white }
		UIView.animate(withDuration: 0.5) {
			(self.stackView.arrangedSubviews[self.animateLblCount] as! UILabel).backgroundColor = #colorLiteral(red: 0.9882352948, green: 0.2392156869, blue: 0.2235294133, alpha: 1)
		}
		collectionView.reloadData()
	}
	
	func refresh() {
		timer.invalidate()
		timer = Timer()
		notLackIndex.removeAll()
		table.removeAll()
		animateLblCount = -1
		isPlaying = false
	}
	
	func modifyArray(_ array: inout [Int]) {
		while array[0] == array[1] || array[0] == array[2] || array[1] == array[2] {
			if array[0] == array[1] {
				array[0] = Int(arc4random_uniform(9))
			}
			if array[0] == array[2] {
				array[0] = Int(arc4random_uniform(9))
			}
			if array[1] == array[2] {
				array[1] = Int(arc4random_uniform(9))
			}
		}
	}
}

// MARK:- UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
	
}

// MARK:- UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return animateLblCount
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return blockCount
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
		
		cell.numLbl.text = "\(table[indexPath.section][indexPath.row])"
		cell.backView.backgroundColor = #colorLiteral(red: 0.2781227827, green: 0.688359201, blue: 0.9917249084, alpha: 1)
		
		if animateLblCount > 0 {
			
			let idx = animateLblCount - 1
			let targetIndex = table[idx].firstIndex(of: testArray[idx])
			
			if idx > 0 && table[idx] == table[idx - 1] {
				notLackIndex.append(idx)
			}
			
			if notLackIndex.contains(indexPath.section) {
				cell.backView.backgroundColor = UIColor.white
			}
			
			if indexPath.section == idx && indexPath.row == targetIndex! {
				cell.backView.backgroundColor = #colorLiteral(red: 0.9882352948, green: 0.2392156869, blue: 0.2235294133, alpha: 1)
			}
			
			
		}
		
		
		
		// hide unnessry label
//		if indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2) {
//			cell.numLbl.isHidden = true
//		}
//		if indexPath.section == 1 && indexPath.row == 2 {
//			cell.numLbl.isHidden = true
//		}
		return cell
	}
}

// MARK:- UICollectionViewFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.frame.width / CGFloat(testArray.count)
		let size = CGSize(width: width, height: 36)
		return size
	}
}
