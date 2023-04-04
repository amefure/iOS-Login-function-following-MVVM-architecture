//
//  AppleAuthModel.swift
//  TestAuth
//
//  Created by t&a on 2023/04/02.
//

import UIKit
import CryptoKit
import AuthenticationServices
import FirebaseAuth

class AppleAuthModel {
    
    // MARK: - シングルトン
    static let shared = AppleAuthModel()
    
    // MARK: - Firebase用
    public var currentNonce:String? = nil
    
    // MARK: - Firebase用
    @available(iOS 13, *)
    public func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    public func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    // MARK: - Firebase用
    
    /// 認証情報を取得
    private func getCredential(authResults:ASAuthorization) -> AuthCredential?{
        let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential
        
        guard let nonce = self.currentNonce else {
//            fatalError("Invalid state: A login callback was received, but no login request was sent.")
            return nil
        }
        guard let appleIDToken = appleIDCredential?.identityToken else {
//            fatalError("Invalid state: A login callback was received, but no login request was sent.")
            return nil
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return nil
        }
        
        let credential:AuthCredential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
        return credential
    }
    
    /// ボタンクリック後の結果分岐処理
    public func switchAuthResult(result:Result<ASAuthorization, Error>) -> AuthCredential?{
            // MARK: - Result
            switch result {
                
            case .success(let authResults):
                
                guard let credential = self.getCredential(authResults: authResults) else{
                    return nil
                }
                return credential
                
            case .failure(let error):
                print("Authorisation failed: \(error.localizedDescription)")
                return nil
            }
        }
    
    // MARK: - Apple ユーザーネーム編集
    public func editUserNameApple(user:User,credential:AuthCredential,name:String,completion : @escaping (Result<Bool, Error>) ->  Void ){
        user.reauthenticate(with: credential) { (authResult, error) in
                if error == nil {
                    let request = user.createProfileChangeRequest()
                    request.displayName = name
                    request.commitChanges { error in
                        if error == nil{
                            completion(.success(true))
                        }else{
                            completion(.failure(error!))
                        }
                    }
                }else{
                    completion(.failure(error!))
                }
            }
        }
}
