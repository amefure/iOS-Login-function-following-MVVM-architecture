//
//  EmailAuthModel.swift
//  TestAuth
//
//  Created by t&a on 2023/04/02.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class EmailAuthModel {
    // MARK: - シングルトン
    static let shared = EmailAuthModel()
    
    // MARK: - リファレンス
    private  let auth = Auth.auth()
    
    // MARK: - Email/passwordログイン
    func signIn(email:String,password:String,completion : @escaping (Result<Bool, Error>) ->  Void ){
        auth.signIn(withEmail: email, password: password) { result, error in
            if error == nil {
                if result?.user != nil{
                    completion(.success(true))
                }else{
                    completion(.failure(AuthErrorCode.userNotFound as! Error))
                }
            }else{
                completion(.failure(error!))
            }
            
        }
    }
    
    // MARK: - 新規登録 - (1)
    func createUser(email:String,password:String,name:String,completion : @escaping (Result<Bool, Error>) ->  Void ){
        auth.createUser(withEmail: email, password: password) { result, error in
            if error == nil {
                if let user = result?.user {
                    self.editUserInfo(user: user, name: name) { result in
                        if result {
                            completion(.success(true))
                        }else{
                            completion(.failure(AuthErrorCode.userNotFound as! Error))
                        }
                    }
                }else{
                    completion(.failure(AuthErrorCode.userNotFound as! Error))
                }
            }else{
                completion(.failure(error!))
            }
            
        }
    }
    
    // MARK: - 新規登録 - (2) ユーザー情報登録
    private func editUserInfo(user:User,name:String,completion: @escaping (Bool) -> Void ) {
        let request = user.createProfileChangeRequest()
        request.displayName = name
        request.commitChanges { error in
            if error == nil{
                completion(true)
                //                確認メール送付
                //                self.sendVerificationMail(user: user) { result in
                //                    completion(result)
                //                }
            }else{
                completion(false)
            }
        }
    }
    // MARK: - 新規登録 - (3) 確認メール送信 [未使用]
    private func sendVerificationMail(user:User,completion: @escaping (Bool) -> Void ) {
        user.sendEmailVerification() { error in
            if error == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    // MARK: - 再認証用クレデンシャル
    private func getCredential(user:User,pass:String)-> AuthCredential{
        return EmailAuthProvider.credential(withEmail: user.email ?? "", password: pass)
    }
    
    // MARK: - email再認証
    public func reAuthUser(pass:String,completion : @escaping (Result<Bool, Error>) ->  Void ){
        if let user = auth.currentUser {
            // emailアカウント再認証
            let credential = self.getCredential(user: user, pass: pass)
            user.reauthenticate(with: credential) { (result, error) in
                if error == nil {
                    completion(.success(true))
                } else {
                    completion(.failure(error!))
                }
            }
        }
    }
    // MARK: - リセットパスワード
    public func resetPassWord(email:String,completion : @escaping (Result<Bool, Error>) ->  Void ){
        auth.sendPasswordReset(withEmail: email) { error in
            if error == nil {
                print("Succress")
                completion(.success(true))
            } else {
                completion(.failure(error!))
            }
        }
    }
    
    
    
    // MARK: - ユーザー情報編集
    public func editUserInfoEmail(name:String,pass:String,completion : @escaping (Result<Bool, Error>) ->  Void ){
        if let user = auth.currentUser {
            reAuthUser(pass: pass) { result in
                switch result {
                case .success(_):
                    let request = user.createProfileChangeRequest()
                    request.displayName = name
                    request.commitChanges { error in
                        if error == nil{
                            completion(.success(true))
                        }else{
                            completion(.failure(error!))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }else{
            completion(.failure(AuthErrorCode.userNotFound as! any Error))
        }
    }
    
    
    //     MARK: - Email編集
    public func updateEmail(email:String,pass:String,completion : @escaping (Result<Bool, Error>) ->  Void ){
        reAuthUser(pass: pass) { result in
            switch result {
            case .success(_):
                self.auth.currentUser?.updateEmail(to: email) { error in
                    if error == nil{
                        completion(.success(true))
                    }else{
                        completion(.failure(error!))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}

