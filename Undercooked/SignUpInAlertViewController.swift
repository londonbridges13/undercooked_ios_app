//
//  SignUpInAlertViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/30/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class SignUpInAlertViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var topLabel: UILabel!
    @IBOutlet var emailTXField: UITextField!
    @IBOutlet var passwordTXField: UITextField!
    
    @IBOutlet var emailView: UIView!
    @IBOutlet var passwordView: UIView!

    @IBOutlet var backButton: UIButton!
    @IBOutlet var goButton: UIButton!

    @IBOutlet var segueHomeButton: UIButton!
    @IBOutlet var segueTopicsButton: UIButton!

    var labeltext : String?
    var email : String?
    var password : String?
    var access_token : String?
    var username : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTXField.delegate = self
        self.passwordTXField.delegate = self
        self.topLabel.text = self.labeltext
        self.emailView.layer.cornerRadius = 5
        self.passwordView.layer.cornerRadius = 5
        self.emailView.layer.borderWidth = 1
        self.passwordView.layer.borderWidth = 1
        self.emailView.layer.borderColor = UIColor.gray.cgColor
        self.passwordView.layer.borderColor = UIColor.gray.cgColor
        self.goButton.layer.cornerRadius = 5

        self.get_client_token()
        
        if self.labeltext == "Sign Up"{
            //sign up
            self.goButton.addTarget(self, action: #selector(SignUpInAlertViewController.sign_up), for: .touchUpInside)
        }else{
            //sign in
            self.goButton.addTarget(self, action: #selector(SignUpInAlertViewController.sign_in), for: .touchUpInside)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissMe(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //textfield 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.emailTXField.isEditing == true{
            self.passwordTXField.becomeFirstResponder()
            return true
        }else{
            self.passwordTXField.resignFirstResponder()
            if self.labeltext == "Sign Up"{
                //sign up
                self.sign_up()
            }else{
                //sign in
                self.sign_in()
            }
            return true
        }
    }
    
    
    func sign_up(){
        print("Signing Up")
        if valid_email(check_email: self.emailTXField.text!) == true{
            self.email = self.emailTXField.text!
            if self.valid_password() == true{
                // send request
                request_sign_up(email: self.email!, password: self.password!, access_token: self.access_token!)
            }else{
                // Invalid Password
                print("Invalid Password")
                
            }
        }else{
            // Invalid Email
            print("Invalid Email")
            
        }
    }
    
    
    func sign_in(){
        print("Signing In")
        if valid_email(check_email: self.emailTXField.text!) == true{
            self.email = self.emailTXField.text!
            if self.valid_password() == true{
                // send request 
                request_sign_in(email: self.email!, password: self.password!, access_token: self.access_token!)
            }else{
                // Invalid Password
                print("Invalid Password")
                
            }
        }else{
            // Invalid Email
            print("Invalid Email")
            
        }
    }
    
    
    func request_sign_in(email : String, password : String, access_token : String, user_token : String = ""){
        
        let parameters: Parameters = [
            "access_token": access_token,
            "uemail": email,
            "upassword": password,
            "utoken": user_token
        ]
        
        Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/signin", method: .post, parameters: parameters).responseJSON { (response) in
            if let result = response.result.value as? NSDictionary{
//                var id = result["id"] as? Int
                var name = result["name"] as? String
                if name != nil{
                    self.username = name!
                    self.set_user_name(name: name!) // This works only if there is a name here
                }
                var user_token = result["access_token"] as? String
                if user_token != nil{
                    // Successfully signed in, segue to Home Tab
                    print(user_token!)
                    self.set_user_token(user_token: user_token!)
                    self.set_user_email_and_password(email: email, password: password)
                    self.segueHomeButton.sendActions(for: .touchUpInside)
                }else{
                    // Invalid Sign In
                    print("Invalid Email/Password")
                }
            }
        }

    }
    
    func request_sign_up(email : String, password : String, access_token : String, user_token : String = ""){
        print("requesting sign up")
        let parameters: Parameters = [
            "access_token": access_token,
            "uemail": email,
            "upassword": password,
            "utoken": user_token
        ]
        
        Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/signup", method: .post, parameters: parameters).responseJSON { (response) in
            if let result = response.result.value as? NSDictionary{
                var name = result["name"] as? String
                if name != nil{
                    self.username = name!
                }
                var new_user_token = result["access_token"] as? String
                if new_user_token != nil{
                    // Successfully signed up, segue to Select Topics
                    print("Successfully signed up, segue to Select Topics")
                    print(new_user_token!)
                    self.set_user_token(user_token: new_user_token!)
                    self.set_user_email_and_password(email: email, password: password)
                    self.segueTopicsButton.sendActions(for: .touchUpInside)
                }else{
                    // Invalid Sign In
                    print("Invalid Email/Password")
                }
            }
        }
    }
    
    
    
    func valid_password() -> Bool{
        if (self.passwordTXField.text?.characters.count)! >= 6{
            // Continue with features
            self.password = self.passwordTXField.text!
            return true
        }else{
            return false
        }
    }
    
    func valid_email(check_email : String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: check_email)
    }
    
    
    func get_client_token(){
        // Grabs the valid token from the user's database
        let realm = try! Realm()
        let user = realm.objects(User).first
        self.access_token = user!.client_token
    }

    func set_user_token(user_token: String){
        // Sets the user's user_token
        let realm = try! Realm()
        let user = realm.objects(User).first
        try! realm.write{
            user!.access_token = user_token
            print("Saved User Token : \(user_token)")
        }
    }
    
    func set_user_email_and_password(email : String, password : String){
        let realm = try! Realm()
        let user = realm.objects(User).first
        try! realm.write{
            user!.password = password
            user!.email = email
        }
    }
    
    func set_user_name(name : String){
        let realm = try! Realm()
        let user = realm.objects(User).first
        try! realm.write{
            user!.name = name
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
