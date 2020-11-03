//
//  SignUpViewController.swift
//  IssueTracker
//
//  Created by cho on 2020/11/02.
//  Copyright © 2020 ralph. All rights reserved.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!

    @IBOutlet weak var idErrorMessageLabel: UILabel!
    @IBOutlet weak var passwordErrorMessageLabel: UILabel!
    @IBOutlet weak var passwordConfirmErrorMessageLabel: UILabel!
    @IBOutlet weak var nickNameErrorMessageLabel: UILabel!

    @IBOutlet weak var signUpButton: UIButton!
    var viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        idTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
        nickNameTextField.delegate = self
        setUI()
        bindUI()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func setUI() {
        idTextField.setLabel("아이디")
        passwordTextField.setLabel("비밀번호")
        passwordConfirmTextField.setLabel("비밀번호 확인")
        nickNameTextField.setLabel("닉네임")
    }

    func bindUI() {
        viewModel.status.idErrorMessage.bind(idErrorLabelUpdate)
        viewModel.status.passwordErrorMessage.bind(passwordErrorLabelUpdate)
        viewModel.status.passwordConfirmErrorMessage.bind(passwordConfirmLabelUpdate)
        viewModel.status.nicknameErrorMessage.bind(nicknameConfirmLabelUpdate)
        //viewModel.status.buttonEnabled.bindAndFire(buttonEnabledCheck)
    }

    func buttonEnabledCheck(idEnable: Bool, passwordEnable: Bool, passwordConfirmEnable: Bool, nicknameEnable: Bool) {
        if idEnable, passwordEnable, passwordConfirmEnable, nicknameEnable {
            self.signUpButton.isUserInteractionEnabled = true
            self.signUpButton.alpha = 1.0
        } else {
            self.signUpButton.isUserInteractionEnabled = false
            self.signUpButton.alpha = 0.3
        }
    }
    
    
    func nicknameConfirmLabelUpdate(nickname: String) {
        if nickname.isEmpty {
            self.nickNameErrorMessageLabel.isHidden = true
        } else {
            self.nickNameErrorMessageLabel.text = nickname
            self.nickNameErrorMessageLabel.isHidden = false
        }
    }
        
    func passwordConfirmLabelUpdate(passwordConfirm: String) {
        if passwordConfirm.isEmpty {
            self.passwordConfirmErrorMessageLabel.isHidden = true
        } else {
            self.passwordConfirmErrorMessageLabel.text = passwordConfirm
            self.passwordConfirmErrorMessageLabel.isHidden = false
        }
    }
    
    
    func idErrorLabelUpdate(id: String) {
        if id.isEmpty {
            self.idErrorMessageLabel.isHidden = true
        } else {
            self.idErrorMessageLabel.text = id
            self.idErrorMessageLabel.isHidden = false
        }
    }
    
    func passwordErrorLabelUpdate(password: String) {
        if password.isEmpty {
            self.passwordErrorMessageLabel.isHidden = true
        } else {
            self.passwordErrorMessageLabel.text = password
            self.passwordErrorMessageLabel.isHidden = false
        }
    }
        
    func showToast(message : String) {
        let width_variable:CGFloat = 100
        let toastLabel = UILabel(frame: CGRect(x: width_variable, y: self.view.frame.size.height-100, width: view.frame.size.width-2*width_variable, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIApplication.shared.keyWindow?.addSubview(toastLabel)
        
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @IBAction func touchedSignUp(_ sender: Any) {
        
        let url = "http://172.30.1.27:5000"
        
        let parameters = ["userId": self.idTextField.text,
                          "password": self.passwordTextField.text,
                          "nickname": self.nickNameTextField.text]
        
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        AF.request(url + "/api/signup", method: .post, parameters: parameters, headers: headers).responseJSON { (response) in
            switch response.result {
            case let .success(json):
                print(json)
                if let dic = json as? [String: String] {
                    let message = dic["message"] ?? ""
                    print(message)
                }
            case let .failure(error):
                print(error)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.action.idTextFieldChanged(self.idTextField.text!)
        viewModel.action.passwordTextFieldChanged(self.passwordTextField.text!)
        viewModel.action.passwordConfirmFieldChanged(self.passwordTextField.text!, self.passwordConfirmTextField.text!)
        viewModel.action.nicknameFieldChanged(self.nickNameTextField.text!)
    }
}
