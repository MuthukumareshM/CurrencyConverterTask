//
//  HomePageViewController.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet var currencyRateTableView: UITableView?
    @IBOutlet var loader: UIActivityIndicatorView?
    var viewModel = BankInfoViewModel()
    lazy var convertRate = 0.0
    
    var currencyRatesList: [String: Double] = [:] {
        didSet {
            currencyRateTableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.bankDetailsDelegate = self
    }
    
    
    @IBAction func validateIban(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Please Enter the IBAN Number to validate", message: nil, preferredStyle: .alert)
        alertController.addTextField{ (textField) in
            textField.placeholder = "AD1200012030200359100100"
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alertController] _ in
            self.handleLoader(show: true)
            let answer = alertController.textFields![0]
            self.viewModel.validateIban(ibanNo: answer.text ?? "")
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
        
    }
    
    @IBAction func convertCurrency(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Please Enter amount to convert", message: nil, preferredStyle: .alert)
        alertController.addTextField{ (textField) in
            textField.placeholder = "1 KWD"
            textField.keyboardType = .decimalPad
        }
        let submitAction = UIAlertAction(title: "Convert", style: .default) { [unowned alertController] _ in
            self.handleLoader(show: true, alwaysRequired: true)
            if let value = alertController.textFields![0].text {
                self.convertRate = Double(value) ?? 0.0
            }
            self.viewModel.convertCurrency()
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
        
    }
    
    private func handleLoader(show: Bool, alwaysRequired: Bool = false) {
        
        DispatchQueue.main.async {
            self.loader?.isHidden = !show
            self.currencyRateTableView?.isHidden = true
            if alwaysRequired{
                self.currencyRateTableView?.isHidden = show
            }
        }
    }
    
}
extension HomePageViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyRatesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as UITableViewCell
        cell = UITableViewCell(style: .value2, reuseIdentifier: "currencyCell")
        
        var content = cell.defaultContentConfiguration()
        content.text = currencyRatesList.keys.map({ $0 })[indexPath.row]
        content.secondaryText = String(currencyRatesList.values.map({ $0 })[indexPath.row] * convertRate)
        cell.contentConfiguration = content
        return cell
    }
    
}

extension HomePageViewController: BankInfoDelegate {
    func sendIBanResponseStatus(status: Bool) {
        handleLoader(show: false)
        let message = status == true ? "successfull" : "failed"
        let alertController = UIAlertController(title: "IBAN validation \(message)", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func sendCurrencyListAndRateDetails(details: [String : Double]) {
        currencyRatesList = details
        handleLoader(show: false, alwaysRequired: true)
    }
}

