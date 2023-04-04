//
//  AuthModel.swift
//  TestAuth
//
//  Created by t&a on 2023/04/02.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import SwiftUI

class AuthModel {

    // MARK: - シングルトン
    static let shared = AuthModel()
    
    // MARK: - リファレンス
    private  let auth = Auth.auth()

    
    // MARK: - 
    public func getCurrentUser() -> User? {
        return auth.currentUser
    }
    
    public let defaultName = "no name"
    
    // MARK: - Sign In for Credential
    public func credentialSignIn(credential: AuthCredential,completion : @escaping (Result<Bool, Error>) ->  Void ){
        self.auth.signIn(with: credential) { (authResult, error) in
            if error == nil {
            if authResult?.user != nil{
                if authResult!.user.displayName == nil{
                    // Appleアカウントの場合は存在しない
                }
                completion(.success(true))
            }
            }else{
                completion(.failure(error!))
            }
        }
    }
    
    // MARK: - サインアウト処理
    public func SignOut(completion : @escaping (Result<Bool, Error>) ->  Void ){
        do{
            try auth.signOut()
            print("SignOut")
            completion(.success(true))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }
    
    // MARK: -  各プロバイダ退会処理 & Appleアカウントは直呼び出し
    public func withdrawal(completion : @escaping (Result<Bool, Error>) ->  Void ){
        if let user = auth.currentUser {
            user.delete { error in
                if error == nil {
                    print("退会成功")
                    completion(.success(true))
                } else {
                    print("退会失敗")
                    completion(.failure(error!))
                }
            }
        }
    }
}


