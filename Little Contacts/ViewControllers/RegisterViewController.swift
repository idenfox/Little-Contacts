//
//  RegisterViewController.swift
//  Little Contacts
//
//  Created by Renzo Paul Chamorro on 27/11/21.
//

import Foundation

import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
    }
    
    private func textfieldErrorDataInput() -> String? {
        if (emailTextfield.text == nil ||
            passwordTextfield.text == nil ||
            emailTextfield.text == "" ||
            passwordTextfield.text == "") {
            return "Por favor ingrese sus datos"
        } else if (emailTextfield.text!.count < 5 ||
                   passwordTextfield.text!.count < 5) {
            return "Tu correo y contraseña deben de tener al menos 5 carácteres y tu nickname al menos 3."
        } else {
            return nil
        }
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        let errorTextField = self.textfieldErrorDataInput()
        if (errorTextField == nil) {
            self.view.activityStartAnimating(activityColor: .yellow, backgroundColor: .clear)
            Auth.auth().createUser(withEmail: self.emailTextfield.text!, password: self.passwordTextfield.text!) { authResult, error in
                if (error == nil) {
                    self.view.activityStopAnimating()
                    self.performSegue(withIdentifier: "registerSegue", sender: self)

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

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
