//
//  AuthErrorModel.swift
//  TestAuth
//
//  Created by t&a on 2023/04/03.
//

import UIKit
import FirebaseAuth

class AuthErrorModel {
    
    // MARK: - Errorハンドリング
   public func setErrorMessage(_ error:Error?) -> String{
        if let error = error as NSError? {
            if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    return  "メールアドレスの形式が違います。"
                case .emailAlreadyInUse:
                    return  "このメールアドレスはすでに使われています。"
                case .weakPassword:
                    return  "パスワードが弱すぎます。"
                case .userNotFound, .wrongPassword:
                    return  "メールアドレス、またはパスワードが間違っています"
                case .userDisabled:
                    return  "このユーザーアカウントは無効化されています"
                default:
                    return  "予期せぬエラーが発生しました。\nしばらく時間を置いてから再度お試しください。"
                }
            }
        }
       return  "予期せぬエラーが発生しました。\nしばらく時間を置いてから再度お試しください。"
    }
}
