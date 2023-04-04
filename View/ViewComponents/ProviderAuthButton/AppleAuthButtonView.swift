//
//  AppleAuthView.swift
//  TestAuth
//
//  Created by t&a on 2023/04/02.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth


struct AppleAuthButtonView: View {
    
    // MARK: - ViewModels
    @ObservedObject var authVM = AuthViewModel.shared
    
    // MARK: - Navigationプロパティ
    @Binding var isActive:Bool
    
    // MARK: -
    let userEditReauthName:String // 変更するユーザー名 or ブランク("")
    
    // MARK: - Flag
    let userWithDrawa:Bool        // AppleUserWithDrawalViewから呼び出されているか
    
    // MARK: - Appleボタン　ボタンタイトル表示用
    private var displayButtonTitle:SignInWithAppleButton.Label{
        if userEditReauthName == "" {
            return .signIn
        }else{
            return .continue
        }
    }
    
    var body: some View {
        
        
        SignInWithAppleButton(displayButtonTitle) { request in
            
            // MARK: - Request
            request.requestedScopes = [.email,.fullName]
            request.nonce = authVM.getHashAndSetCurrentNonce()
            
        } onCompletion: { result in
            
            guard let credential = authVM.switchAuthResult(result: result) else{
                return
            }
            // MARK: - 以下ボタンアクション分岐
            
            
            if userEditReauthName == ""{
                
                if userWithDrawa == false {
                    // MARK: - ログイン
                    authVM.credentialAppleSignIn(credential: credential) { result in
                        authVM.resetErrorMsg()
                        isActive = true
                    }
                }else{
                    // MARK: - 退会
                    authVM.withdrawal(completion: ) { result in
                        if result {
                            isActive = true // EditUserInfo成功アラート表示用
                        }
                    }
                }
                
            }else{
                // MARK: - ユーザーネーム変更 未実装
//                authVM.editUserInfo(credential: credential, name: userEditReauthName) { result in
//                    if result {
//                        isActive = true // EditUserInfo成功アラート表示用
//                    }
//                }
            }
            
        }.frame(width: 200, height: 40)
            .signInWithAppleButtonStyle(.black)
    }
}




