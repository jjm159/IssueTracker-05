//
//  ValidationChecker.swift
//  IssueTracker
//
//  Created by cho on 2020/10/28.
//  Copyright © 2020 ralph. All rights reserved.
//

import Foundation

protocol Validator {
    var pass: validateMessage { get }
    
    func validate(input: String) -> validateMessage
}

enum validateMessage: String {
    case invalidIdlength = "아이디는 6~16자만 입력 가능합니다."
    case invalidPwlength = "비밀번호는 6~12자만 입력 가능합니다."
    case emptyId = "아이디를 입력하세요"
    case emptyPassword = "비밀번호를 입력하세요"
    case validId = "사용 가능한 아이디입니다."
    case validPassword = "사용 가능한 비밀번호입니다."
}

class IdValidationChecker: Validator {
    
    var pass: validateMessage {
        get { .validId }
    }
    
    func validate(input: String) -> validateMessage {
        if input.isEmpty {
            return .emptyId
        }
        
        if input.count < 6 || input.count > 16 {
            return .invalidIdlength
        }
        
        return .validId
    }
    
}

class PasswordValidationChecker: Validator {
    
    var pass: validateMessage {
        get { .validPassword }
    }
    
    func validate(input: String) -> validateMessage {
        if input.isEmpty {
            return .emptyPassword
        }
        
        if input.count < 6 || input.count > 12 {
            return .invalidPwlength
        }
        return .validPassword
    }
    
}
