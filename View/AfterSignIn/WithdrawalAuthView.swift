//
//  WithdrawalAuthView.swift
//  TestAuth
//
//  Created by t&a on 2023/04/03.
//

import SwiftUI

struct WithdrawalAuthView: View {
    
    // MARK: - ViewModels
    @ObservedObject var authVM = AuthViewModel.shared
    
    // MARK: - Navigationプロパティ
    @State var isActive:Bool = false
    
    @State  var password:String = ""
    
    var body: some View {
        VStack{
            
            // MARK: - 透明のNavigationLink
            NavigationLink(isActive: $isActive, destination:{ LoginAuthView()}, label: {
                EmptyView()
            })
            
            // MARK: - Email
            SecureInputView(password: $password)
            
            Button {
                if !password.isEmpty{
                    authVM.credentialEmailWithdrawal(password:password) { result in
                        if result {
                            isActive = true
                        }
                    }
                }
                
            } label: {
                Text("Email退会")
            }.frame(width:170)
                .padding()
                .background(.cyan)
                .tint(.white)
                .cornerRadius(5)
                .padding()
            
            Divider().padding()
            
            // MARK: - Google
            Button {
                authVM.credentialGoogleWithdrawal { result in
                    if result {
                        isActive = true
                    }
                }
            } label: {
                Text("Google退会")
            }.frame(width:170)
                .padding()
                .background(.cyan)
                .tint(.white)
                .cornerRadius(5)
                .padding()
            
            Divider().padding()
            
            // MARK: - Apple
            Text("Apple退会")
            AppleAuthButtonView(isActive: $isActive, userEditReauthName: "", userWithDrawa: true)
        }
    }
}

struct WithdrawalAuthView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalAuthView()
    }
}
