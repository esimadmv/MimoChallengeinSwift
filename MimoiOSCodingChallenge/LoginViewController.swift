//
//  LoginViewController.swift
//  MimoiOSCodingChallenge
//
//  Created by Ehsan on 2017-09-23.
//  Copyright © 2017 Mimohello GmbH. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController,UITextFieldDelegate {

    var welcome = UITextView()
    var isLoginView:Bool = true // set true for login and false for sign up
    
    var emailTextField = UITextField()
    var passTextField = UITextField()
    let button = UIButton()
    let urlOrigin = "https://mimo-test.auth0.com"
    let clr_mimo = UIColor(red: 0, green: 200/255, blue: 96/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupView()
        addButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // handle current user
        if (User.currentUser() != nil){
            onSuccess()
        }
    }
    
    func setupView(){
        
        welcome.frame = CGRect(x: 60, y: 50, width: view.bounds.width - 120, height: 150)
        welcome.text = "WELCOME TO MIMO iOS CHALLENGE"
        welcome.textColor = clr_mimo
        welcome.textAlignment = .center
        welcome.font = UIFont(name: "Helvetica", size: 30)
        welcome.isUserInteractionEnabled = false
        self.view.addSubview(welcome)
        
        
        
        emailTextField = addTextField(y: view.bounds.height/2 ,labelText: "Email Address:")
        emailTextField.delegate = self
        emailTextField.tag = 0
        emailTextField.keyboardType = .emailAddress
        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.size.height))
        emailTextField.leftView = paddingView1
        emailTextField.leftViewMode = .always
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.none
        
        
        
        passTextField = addTextField(y: view.bounds.height/2 + view.bounds.height/8,labelText: "Password:")
        passTextField.delegate = self
        passTextField.tag = 1
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passTextField.frame.size.height))
        passTextField.leftView = paddingView2
        passTextField.leftViewMode = .always
        passTextField.isSecureTextEntry = true
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    fileprivate func addButton() {
        button.frame = CGRect(x: 30, y: view.bounds.height/2 + view.bounds.height/4, width: view.bounds.width - 60, height: 40)
        if (isLoginView){
            button.setTitle("Login".uppercased(), for: .normal)
            button.addTarget(self, action: #selector(signinPressed(_:)), for: .touchUpInside)
        } else {
            button.setTitle("Sign Up".uppercased(), for: .normal)
            button.addTarget(self, action: #selector(signupPressed(_:)), for: .touchUpInside)
        }
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = clr_mimo
        button.layer.cornerRadius = 5
        view.addSubview(button)
    }
    
    
    
    @objc fileprivate func signinPressed(_: UIButton) {
        button.isEnabled = false
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(disableLogin), userInfo: nil, repeats: false)
        // handle login
        if emailTextField.text == "" || passTextField.text == "" {
            showAlert(title: "Empty Field!", message: "You should fill both username and password fields, please try again!")
        } else {
            signinUser(email: emailTextField.text!, password: passTextField.text!)
        }
    }
    
    
    @objc fileprivate func signupPressed(_: UIButton) {
        button.isEnabled = false
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(disableLogin), userInfo: nil, repeats: false)
        if emailTextField.text == "" || passTextField.text == "" {
            showAlert(title: "Empty Field!", message: "You should fill both username and password fields, please try again!")
        } else {
            signupUser(email: emailTextField.text!, password: passTextField.text!)
        }
    }
    
    func signupUser(email:String,password:String){
        // Call API
        let url = urlOrigin + "/dbconnections/signup"
        
        let parameters = ["client_id": "PAn11swGbMAVXVDbSCpnITx5Utsxz1co",
                          "email": email,
                          "password": password,
                          "connection": "Username-Password-Authentication",
                          "grant_type": "password",
                          "scope": "openid profile email"]
        
        // CAll AUTH API to Login User
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            if let json = response.result.value as? [String:AnyObject] {
                if let responseObj = response.response {
                    if responseObj.statusCode >= 200 && responseObj.statusCode <= 299 {
                        self.signinUser(email: email, password: password)
                    }
                    else {
                        self.showAlert(title: json["code"] as! String, message: json["description"] as! String)
                    }
                }
            }
        }
    }
    
    func signinUser(email:String,password:String){
        // Call API
        let url = urlOrigin + "/oauth/ro"
        
        let parameters = ["client_id": "PAn11swGbMAVXVDbSCpnITx5Utsxz1co",
                          "username": email,
                          "password": password,
                          "connection": "Username-Password-Authentication",
                          "grant_type": "password",
                          "scope": "openid profile email"]
        
        // CAll AUTH API to Login User
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            if let json = response.result.value as? [String:AnyObject] {
                if let responseObj = response.response {
                    if responseObj.statusCode >= 200 && responseObj.statusCode <= 299 {
                        do {
                            try User.user.initialize(json: json as AnyObject,email:email)
                            self.onSuccess()
                        } catch let error {
                            self.showAlert(title: json["error"] as! String, message: error.localizedDescription)
                        }
                    }
                    else {
                        self.showAlert(title: json["error"] as! String, message: json["error_description"] as! String)
                    }
                }
            }
        }
    }
    
    fileprivate func addTextField(y: CGFloat,labelText: String) -> UITextField {
        let textField = UITextField(frame: CGRect(x: 30, y: y, width: view.bounds.width - 60, height: 40))
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        
        view.addSubview(textField)
        
        
        let label = UILabel(frame: CGRect(x: 30, y: y - 20, width: view.bounds.width - 60, height: 20))
        label.text = labelText
        label.textColor = .lightGray
        view.addSubview(label)
        return textField
    }
    
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1;
        if let nextResponder: UIResponder? = textField.superview!.viewWithTag(nextTag){
            nextResponder?.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return false
    }
    
    
    func keyboardWillShow(_ sender: Notification) {
        let info = (sender as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.view.frame.origin.y = -keyboardFrame.size.height/3
        
    }
    
    func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
        
    }
    
    func disableLogin() {
        button.isEnabled = true
    }

    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func onSuccess(){
        let vc:SettingsViewController = SettingsViewController.init()
        self.present(vc, animated: true, completion: nil)
    }


}
