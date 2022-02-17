//
//  ViewController.swift
//  SlotMachine
//
//  Created by Denis Kuzmin on 16.02.2022.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var slotsData = Array(repeating:"🦖", count: 3)
    var subscriptions = Set<AnyCancellable>()
    
    let maxPickerRow = 50

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self

        self.pickerView.selectRow(self.maxPickerRow / 2, inComponent: 0, animated: true)
        self.pickerView.selectRow(self.maxPickerRow / 2, inComponent: 1, animated: true)
        self.pickerView.selectRow(self.maxPickerRow / 2, inComponent: 2, animated: true)
        
        let viewModel = GameViewModel(buttonPressed: playButton.tapPublisher.share().eraseToAnyPublisher())
        
        viewModel.slot?.sink(receiveValue: { data in
            self.pickerView.selectRow(Int.random(in: (0...self.maxPickerRow - 10)), inComponent: 0, animated: true)
            self.pickerView.selectRow(Int.random(in: (0...self.maxPickerRow - 10)), inComponent: 1, animated: true)
            self.pickerView.selectRow(Int.random(in: (0...self.maxPickerRow - 10)), inComponent: 2, animated: true)
            self.slotsData = data
        })
            .store(in: &subscriptions)
        
        viewModel.labels?.sink(receiveValue: { labels in
            self.playButton.setTitle(labels.0, for: .normal)
            self.infoLabel.text = labels.1
        })
            .store(in: &subscriptions)
    }


}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        maxPickerRow
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        slotsData[component]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        75
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        75
    }
}
