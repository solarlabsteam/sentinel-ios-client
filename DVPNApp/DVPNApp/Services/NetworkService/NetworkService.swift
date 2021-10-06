//
//  NetworkService.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 29.09.2021.
//

import Foundation
import Alamofire
import WireGuardKit

private struct Constants {
    let ipTimeout: TimeInterval = 10
    let apiCheckURL = "https://api.ipify.org"
}

private let constants = Constants()

final class NetworkService {}

extension NetworkService: NetworkServiceType {
    func fetchConnectionData(
        remoteURLString: String,
        id: UInt64,
        accountAddress: String,
        signature: String,
        completion: @escaping (Result<(Data, PrivateKey), Error>) -> Void
    ) {
        guard var components = URLComponents(string: remoteURLString) else {
            completion(.failure(ConnectionModelError.invalidURL))
            return
        }
        components.scheme = "http"

        guard let urlString = components.string, let remoteURL = URL(string: urlString) else {
            completion(.failure(ConnectionModelError.invalidURL))
            return
        }

        let url = remoteURL.appendingPathComponent(
            "accounts/\(accountAddress)/sessions/\(id)",
            isDirectory: false
        )

        let wgKey = PrivateKey()
        let parameters: [String: Any] = [
            "key" : wgKey.publicKey.base64Key,
            "signature" : signature
        ]

        struct Result: Codable {
            let success: Bool
            let result: String?
        }

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseDecodable() { (response: DataResponse<Result, AFError>) in
                switch response.result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let infoResult):
                    guard infoResult.success, let stringData = infoResult.result else {
                        completion(.failure(ConnectionModelError.connectionParsingFailed))
                        return
                    }
                    guard let data = Data(base64Encoded: stringData), data.bytes.count == 58 else {
                        completion(.failure(ConnectionModelError.connectionParsingFailed))
                        return
                    }

                    completion(.success((data, wgKey)))
                }
            }
    }
    
    func fetchIP(completion: @escaping (String) -> Void) {
        AF.request(constants.apiCheckURL) { $0.timeoutInterval = constants.ipTimeout }
            .responseString { response in
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    completion(L10n.Home.Status.Connection.lost)
                case .success(let ipAddress):
                    completion(ipAddress)
                }
            }
    }
}
