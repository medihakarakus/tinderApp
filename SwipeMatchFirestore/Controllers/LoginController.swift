//
//  LoginController.swift
//  SwipeMatchFirestore
//
//  Created by Mediha Karakuş on 03.05.23.
//

import UIKit
import Firebase
import JGProgressHUD

protocol LoginControllerDelegate {
    func didFinishLoggingIn()
}

class LoginController: UIViewController {
    var delegate: LoginControllerDelegate?
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter password"
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton
        ])
        sv.distribution = .fillEqually
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()

    let loginVM = LoginViewModel()
    
    @objc func handleTextChange(textField: UITextField) {
      if textField == emailTextField {
            loginVM.email = textField.text
        }else {
            loginVM.password = textField.text
        }
    }
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.layer.cornerRadius = 22
        button.backgroundColor = .lightGray
        button.isEnabled = false
        button.setTitleColor(.darkGray, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let logingHUD = JGProgressHUD(style: .dark)
    @objc fileprivate func handleLogin() {
        loginVM.performLogin { [weak self] err in
            self?.logingHUD.dismiss(animated: true)
            if let err = err {
                self?.showHUDWithError(error: err)
                return
            }
            print("Logged in successfully")
            self?.dismiss(animated: true, completion: {
                self?.delegate?.didFinishLoggingIn()
            })
        }
    }
    
    func showHUDWithError(error: Error) {
        logingHUD.dismiss()
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed to log in"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4)
    }
    
    let backToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        setupLayout()
        setupLoginVMObserver()
        
    }
    
    fileprivate func setupLoginVMObserver() {

        loginVM.isFormValid.bind { [unowned self] isFormValid in
            guard let isFormValid = isFormValid else { return }
            self.loginButton.isEnabled = isFormValid
            self.loginButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1) : .lightGray
            self.loginButton.setTitleColor(isFormValid ? .white : .darkGray, for: .normal)
        }

        loginVM.isLoggingIn.bind { [unowned self] isLoging in
            if isLoging == true {
                self.logingHUD.textLabel.text = "Login"
                logingHUD.show(in: view)
            } else {
                self.logingHUD.dismiss(animated: true)
            }
        }

    }

    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(backToRegisterButton)
        backToRegisterButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.3725490196, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
    
}
