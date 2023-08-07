//
//  NetworkServiceAlamofire.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 07/08/23.
//

import Foundation
import CommonCrypto
import Alamofire

struct ApiKeys {
    static let apiKey = "UEdaNdpiNGTzxNFOrGKhrINnmFqYso6N"
}

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    var session: URLSession!
    var afSession: Session!
    
    private override init() {
        super.init()
        
        session = URLSession.init(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        
        let evaluators: [String: ServerTrustEvaluating] = [
            "api.apilayer.com": PublicKeysTrustEvaluator()
        ]
        
        let manager = ServerTrustManager(evaluators: evaluators)
        
        afSession = Session.init(serverTrustManager: manager)
    }
    
    func afRequest<T: Decodable>(url: URL?, expecting: T.Type, completion: @escaping (_ data: T?, _ error: Error?)-> ()) {
        
        let headers: HTTPHeaders = [
            "apikey": ApiKeys.apiKey,
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        afSession.request(url?.absoluteString ?? "", headers: headers)
            .validate()
            .response { response in
                
                switch response.result {
                    
                case .success(let data):
                    guard let data else {
                        completion(nil, NSError.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"something went wrong"]))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let response = try decoder.decode(T.self, from: data)
                        completion(response, nil)
                    } catch {
                        completion(nil, error)
                    }
                    
                case .failure(let error):
                    switch error {
                        
                    case .serverTrustEvaluationFailed(let reason):
                        print(reason)
                        completion(nil, NSError.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Pinning Failed"]))
                        
                    default:
                        completion(nil, error)
                    }
                    
                }
            }
    }
}


protocol APIClient {
    func validateIbanRequest(for url: String)
    //    func createRequest(for url: String) -> URLRequest?
    //    func executeRequest<T: Codable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
}


extension NetworkManager: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust, let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return
        }
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
        
        let pathToCertificate = Bundle.main.path(forResource: "sni.cloudflaressl.com", ofType: "cer")
        let localCertificateData: NSData = NSData.init(contentsOfFile: pathToCertificate!)!
        
        if (isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)) {
            let credential: URLCredential = URLCredential(trust: serverTrust)
            print("Certification pinning is successfull")
            completionHandler(.useCredential, credential)
        } else {
            
            print("Certification pinning is failed")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

