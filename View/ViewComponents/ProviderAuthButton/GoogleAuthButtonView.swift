//
//  ContentView.swift
//  TestAuth
//
//  Created by t&a on 2023/03/31.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct GoogleAuthButtonView: View {
    
    // MARK: - Navigationプロパティ
    @Binding var isActive:Bool
    
    // MARK: - ViewModels
    @ObservedObject var authVM = AuthViewModel.shared
    
    var body: some View {
        Button(action: {
            authVM.credentialGoogleSignIn { result in
                if result {
                    authVM.resetErrorMsg()
                    isActive = true
                }
            }
        }, label: {
            Text("Sign in with Google")
        }).frame(width:170)
            .padding()
            .background(.cyan)
            .tint(.white)
            .cornerRadius(5)
            .padding()
    }
}

