//
//  PasswordResetView.swift
//  TestAuth
//
//  Created by t&a on 2023/04/03.
//

import SwiftUI
import FirebaseAuth

struct PasswordResetView: View {
    
    // MARK: - ViewModels
    @ObservedObject var authVM = AuthViewModel.shared
    private let validationVM = ValidationViewModel()
    
    // MARK: - Inputプロパティ
    @State var email:String = ""
    
    // MARK: - Inputプロパティ
    @State var wasSent:Bool = false
        
    var body: some View {
        VStack{
            
            Text("パスワードを忘れてしまった場合は登録しているメールアドレスを入力してください。\n入力されたメールアドレスに再設定用のメールが届きますので記載されているURLから再設定を行ってください。").padding()
            
            if wasSent{
                Text("メールアドレス宛に再設定用のメールを送信しました。")
            }
            
            // MARK: - エラーメッセージ
            ErrorMessageView()
            
            TextField("メールアドレス", text: $email).padding().textFieldStyle(.roundedBorder)
            
            Button(action: {
                if validationVM.validateEmail(email: email) {
                    authVM.resetPassWord(email: email) { result in
                        wasSent = result
                    }
                }
            }, label: {
                Text("メール送信")
            }).frame(width:80)
                .padding()
                .background(.cyan)
                .tint(.white)
                .cornerRadius(5)
                .padding()
        }.onAppear {
            authVM.resetErrorMsg()
        }
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}

