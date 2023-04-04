//
//  ContentView.swift
//  TestAuth
//
//  Created by t&a on 2023/04/02.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - ViewModels
    @ObservedObject var authVM = AuthViewModel.shared
    
    // MARK: - Navigationプロパティ
    @State var isActive:Bool = false
    @State var isActive2:Bool = false
    
    @State  var password:String = ""
    
    var body: some View {
        VStack{
            
            // MARK: - 透明のNavigationLink
            NavigationLink(isActive: $isActive2, destination:{ LoginAuthView()}, label: {
                EmptyView()
            })
            
            Text("ようこそ！")
            Text("\(authVM.getCurrentUser()?.displayName ?? "Appleアカウント")さん")
            
            Button {
                authVM.signOut { result in
                    if result {
                        isActive2 = true
                    }
                }
            } label: {
                Text("SignOut")
            }.frame(width:70)
                .padding()
                .background(.cyan)
                .tint(.white)
                .cornerRadius(5)
                .padding()
            
            
            NavigationLink(isActive: $isActive, destination:{ WithdrawalAuthView()}, label: {
                Text("退会する")
            }).frame(width:70)
                .padding()
                .background(.cyan)
                .tint(.white)
                .cornerRadius(5)
                .padding()
   
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
