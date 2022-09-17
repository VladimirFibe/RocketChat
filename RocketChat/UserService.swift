import Foundation
import Moya
import CryptoKit
import CommonCrypto

public typealias JSONObject = [String: Any]

enum UserService {
    case login(username: String, password: String)
}

extension UserService: TargetType {
    var baseURL: URL {
        URL(string: "https://motiw.rocket.chat/api/v1/")!
    }
    
    var path: String {
        switch self {
        case .login: return "method.callAnon/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login: return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .login(let username, let password):
            let email = username.contains("@") ? "email" : "username"
            let digest = password.sha256()
            let message: JSONObject = [
              "msg": "method",
              "id": "3",
              "method": "login",
              "params": [
                [
                  "user": [email: username],
                  "password": [
                    "digest": digest,
                    "algorithm": "sha-256"
                  ]
                ]
              ]
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: message, options: [])
            let decoded = String(data: jsonData, encoding: .utf8)!
            let parameters = ["message": decoded]
            print("DEBUG: \(parameters)")
            return .requestParameters(
              parameters: parameters,
              encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
}

extension String {
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}

extension Data {
    public func sha256() -> String {
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }
        return hexString
    }
}
