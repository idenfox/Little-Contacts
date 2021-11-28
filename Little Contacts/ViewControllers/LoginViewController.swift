//
//  ViewController.swift
//  Little Contacts
//
//  Created by Renzo Paul Chamorro on 27/11/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func textfieldErrorDataInput() -> String? {
        if (emailTextfield.text == nil ||
            passwordTextfield.text == nil ||
            emailTextfield.text == "" ||
            passwordTextfield.text == "") {
            return "Por favor ingrese sus datos"
        } else {
            return nil
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        let errorTextField = self.textfieldErrorDataInput()
        if (errorTextField == nil) {
            self.view.activityStartAnimating(activityColor: .brown, backgroundColor: .clear)
            Auth.auth().signIn(withEmail: self.emailTextfield.text!, password: self.passwordTextfield.text!) { authResult, error in
                if (error == nil) {
                    self.view.activityStopAnimating()
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                } else {
                    self.view.activityStopAnimating()
                    let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "¡Verifica tus datos!", message: errorTextField!, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

extension UIView{
//MARK: - Activity Object
    func activityStartAnimating(activityColor: UIColor, backgroundColor: UIColor) {
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = 475647
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
        
        backgroundView.addSubview(activityIndicator)

        self.addSubview(backgroundView)
    }

    func activityStopAnimating() {
        if let background = viewWithTag(475647){
            background.removeFromSuperview()
        }
        self.isUserInteractionEnabled = true
    }
}
