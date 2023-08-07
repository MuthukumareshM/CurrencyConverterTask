//
//  BankInfoViewModel.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import Foundation
import Alamofire

protocol BankInfoDelegate: AnyObject {
    func sendCurrencyListAndRateDetails(details: [String: Double])
    func sendIBanResponseStatus(status: Bool)
}

class BankInfoViewModel {
    weak var bankDetailsDelegate: BankInfoDelegate?
    
    init() {}
    
    let asyncQueue = DispatchQueue.global(qos: .utility)
    
    func validateIban(ibanNo: String?) {
        if Connectivity.isConnectedToInternet {
            guard let ibanNo = ibanNo else { return }
            let url = URL(string:"\(APIEndpoints.baseUrl)bank_data/iban_validate?iban_number=\(ibanNo)")
            NetworkManager.shared.afRequest(url: url, expecting: IBanResponseModel.self) { data, error  in
                if let data = data, data.valid {
                    self.bankDetailsDelegate?.sendIBanResponseStatus(status: data.valid)
                }
                else{
                    self.bankDetailsDelegate?.sendIBanResponseStatus(status: false)
                }
                
            }
        }
        else {
            print("Please check you internet connection")
        }
    }
    
    func convertCurrency(){
        if Connectivity.isConnectedToInternet {
            let url = URL(string:"\(APIEndpoints.baseUrl)fixer/latest?symbols=&base=KWD")
            NetworkManager.shared.afRequest(url: url, expecting: CurrencyRatesModel.self) { data, error  in
                if let data = data, data.success {
                    print("data Success")
                    self.bankDetailsDelegate?.sendCurrencyListAndRateDetails(details: data.rates)
                }
                else{
                    print("data Failure")
                }
                
            }
        }
    }
}
