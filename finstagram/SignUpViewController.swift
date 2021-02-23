//
//  SignUpViewController.swift
//  finstagram
//
//  Created by Luciano Handal on 2/22/21.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signup(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        if (email == "") {
            print("Email empty")
            return
        }
        
        if (password == "") {
            print("Password empty")
            return
        }
        
        if (password != confirmField.text){
            print("Passwords do not match")
            return
        }
        
        print("Will create an ccount for email \(email) with password \(password)")
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let _eror = error {
                print(_eror.localizedDescription )
            }else{
                print(result ?? "Success")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
