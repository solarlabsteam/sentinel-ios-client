//
//  NetworkService.swift
//  SOLAR dVPN
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

enum NetworkServiceError: LocalizedError {
    case invalidURL
    case connectionParsingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.Connection.Error.invalidURL
        case .connectionParsingFailed:
            return L10n.Error.connectionParsingFailed
        }
    }
}

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
            completion(.failure(NetworkServiceError.invalidURL))
            return
        }
        components.scheme = "http"

        guard let urlString = components.string, let remoteURL = URL(string: urlString) else {
            completion(.failure(NetworkServiceError.invalidURL))
            return
        }

        let url = remoteURL.appendingPathComponent(
            "accounts/\(accountAddress)/sessions/\(id)",
            isDirectory: false
        )

        let wgKey = PrivateKey()
        let parameters: [String: Any] = [
            "key": wgKey.publicKey.base64Key,
            "signature": signature
        ]

        struct Result: Codable {
            let success: Bool
            let result: String?
        }

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseDecodable { (response: DataResponse<Result, AFError>) in
                switch response.result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let infoResult):
                    guard infoResult.success, let stringData = infoResult.result else {
                        completion(.failure(NetworkServiceError.connectionParsingFailed))
                        return
                    }
                    guard let data = Data(base64Encoded: stringData), data.bytes.count == 58 else {
                        completion(.failure(NetworkServiceError.connectionParsingFailed))
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
                    completion(L10n.Connection.Status.Connection.lost)
                case .success(let ipAddress):
                    completion(ipAddress)
                }
            }
    }
}
