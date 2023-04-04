//
//  AuthViewModel.swift
//  TestAuth
//
//  Created by t&a on 2023/04/02.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import AuthenticationServices // Apple

class AuthViewModel:ObservableObject {
    
    // MARK: - シングルトン
    static let shared = AuthViewModel()
    
    private var auth = AuthModel.shared
    private let emailAuth = EmailAuthModel.shared
    private let googleAuth = GoogleAuthModel.shared
    private let appleAuth = AppleAuthModel.shared
    
    private let errModel = AuthErrorModel()
    
    @Published var errMessage:String = ""
    
    private func switchResultAndSetErrorMsg(_ result:Result<Bool,Error>) -> Bool{
        switch result {
        case .success(_) :
            return true
        case .failure(let error) :
            print(error.localizedDescription)
            self.errMessage = self.errModel.setErrorMessage(error)
            return false
        }
    }
    
    public func resetErrorMsg(){
        self.errMessage = ""
    }
    
    // MARK: -
    public func getCurrentUser() -> User? {
        return self.auth.getCurrentUser()
    }
    
    /// サインアウト
    public func signOut(completion: @escaping (Bool) -> Void ) {
        self.auth.SignOut { result in
            completion(self.switchResultAndSetErrorMsg(result))
        }
    }
    
    /// 退会
    public func withdrawal(completion: @escaping (Bool) -> Void ) {
        self.auth.withdrawal { result in
            completion(self.switchResultAndSetErrorMsg(result))
        }
    }
    
    
}

// MARK: - Email
extension AuthViewModel {
    
    /// サインイン
    public func emailSignIn(email:String,password:String,completion: @escaping (Bool) -> Void ) {
        emailAuth.signIn(email: email, password: password) { result in
            completion(self.switchResultAndSetErrorMsg(result))
        }
    }
    
    /// 新規登録
    public func createEmailUser(email:String,password:String,name:String,completion: @escaping (Bool) -> Void ) {
        emailAuth.createUser(email: email, password: password, name: name) { result in
            completion(self.switchResultAndSetErrorMsg(result))
        }
    }
    
    /// 再認証→退会
    public func credentialEmailWithdrawal(password:String,completion: @escaping (Bool) -> Void ) {
        emailAuth.reAuthUser(pass: password) { result in
            if self.switchResultAndSetErrorMsg(result) {
                self.withdrawal { result in
                    completion(result)
                }
            }
        }
    }
    
    /// リセットパスワード
    public func resetPassWord(email:String,completion: @escaping (Bool) -> Void ) {
        emailAuth.resetPassWord(email: email) { result in
            completion(self.switchResultAndSetErrorMsg(result))
        }
    }
    
}

// MARK: - Google
extension AuthViewModel {
    
    /// サインイン
    public func credentialGoogleSignIn(completion: @escaping (Bool) -> Void ) {
        googleAuth.getCredential { credential in
            if credential != nil {
                self.auth.credentialSignIn(credential: credential!) { result in
                    completion(self.switchResultAndSetErrorMsg(result))
                }
            }
        }
    }
    
    /// 再認証→退会
    public func credentialGoogleWithdrawal(completion: @escaping (Bool) -> Void ) {
        self.credentialGoogleReaAuth { result in
            if result {
                self.withdrawal { result in
                    completion(result)
                }
            }
        }
    }
    
    /// 再認証
    private func credentialGoogleReaAuth(completion: @escaping (Bool) -> Void ) {
        googleAuth.getCredential { credential in
            if credential != nil {
                self.googleAuth.reAuthUser(user: self.auth.getCurrentUser()!, credential: credential!) { result in
                    completion(self.switchResultAndSetErrorMsg(result))
                }
            }
        }
    }
    
}

// MARK: - Apple
extension AuthViewModel {
    
    ///  サインイン
    public func credentialAppleSignIn(credential:AuthCredential,completion: @escaping (Bool) -> Void ) {
        self.auth.credentialSignIn(credential: credential) { result in
            print("Apple Login")
            completion(self.switchResultAndSetErrorMsg(result))
        }
    }
    
    /// Firebase
    public func getHashAndSetCurrentNonce() -> String {
        let nonce = appleAuth.randomNonceString()
        appleAuth.currentNonce = nonce
        return appleAuth.sha256(nonce)
    }
    
    /// ボタンクリック後の結果分岐処理
    public func switchAuthResult(result:Result<ASAuthorization, Error>) -> AuthCredential?{
        return appleAuth.switchAuthResult(result: result)
    }
    
    //    public func editUserInfo(credential:AuthCredential,name:String,completion: @escaping (Bool) -> Void ) {
    //        if let user = auth.getCurrentUser() {
    //            appleAuth.editUserNameApple(user: user, credential: credential, name: name) { result in
    //                completion(result)
    //            }
    //        }
    //    }
}
