//
//  GoogleAuthModel.swift
//  TestAuth
//
//  Created by t&a on 2023/04/01.
//


import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class GoogleAuthModel {
    
    // MARK: - シングルトン
    static let shared  = GoogleAuthModel()
    
    // MARK: -  インスタンス
    private let g_instance = GIDSignIn.sharedInstance
    
    
    init(){
        setting()
    }
    
    private func setting(){
        guard let clientID:String = FirebaseApp.app()?.options.clientID else { return }
        let config:GIDConfiguration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    private var rootViewController:UIViewController {
        let windowScene:UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return (windowScene?.windows.first!.rootViewController!)!
    }
    
    /// 認証情報を取得
    public func getCredential(completion: @escaping (AuthCredential?) -> Void ) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self.rootViewController) { result, error in
            guard error == nil else {
                print("GIDSignInError: \(error!.localizedDescription)")
                return completion(nil)
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return completion(nil)
            }
            let credential:AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: user.accessToken.tokenString)
            
            completion(credential)
        }
    }
    
    /// 再認証
    public func reAuthUser(user:User,credential:AuthCredential,completion: @escaping (Result<Bool, Error>) ->  Void ){
        user.reauthenticate(with: credential) { result, error in
            if error == nil {
                completion(.success(true))
            } else {
                completion(.failure(error!))
            }
        }
    }
    
}




