//
//  ViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/28/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import Jelly
import NVActivityIndicatorView

class ViewController: UIViewController {

    var actIndi : NVActivityIndicatorView?
    var jellyAnimator: JellyAnimator?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.start_loading()
        var delayInSeconds = 0.65
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.check_for_user()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func check_for_user(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil{
            // Check on credentials
            if user!.email != nil && user!.password != nil && user!.client_token != nil{
                // Sign In again
                self.request_sign_in(email: user!.email!, password: user!.password!, access_token: user!.client_token!)
                
            }else{
                // Onboarding process, no email or password set
                print("Onboarding process, no email or password set")
                self.segue_to_onboarding()
            }
        }else{
            // Onbording process, no user found
            print("Onboarding process, no user found")
            self.segue_to_onboarding()
        }
    }
    
    
    
    func request_sign_in(email : String, password : String, access_token : String, user_token : String = ""){
        print("requesting sign in")
        
        let parameters: Parameters = [
            "access_token": access_token,
            "uemail": email,
            "upassword": password,
            "utoken": user_token
        ]
        
        Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/signin", method: .post, parameters: parameters).responseJSON { (response) in
            if let result = response.result.value as? NSDictionary{
                print("recieved user creds")

                var user_token = result["access_token"] as? String
                if user_token != nil{
                    // Successfully signed in, segue to Home Tab
                    print(user_token!)
                    self.set_user_token(user_token: user_token!)
                    // Go to Home Tab
                    self.segue_to_home_tab()
                }else{
                    // Invalid Sign In
                    print("Invalid Email/Password. Sign in again")
                    // Sign in again
                    self.sign_in_again()
                }
            }else{
                // Invalid Sign In
                print("No Response...Invalid Email/Password. Sign in again")
                // Sign in again
                self.sign_in_again()
            }
        }
        
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


    func sign_in_again(){
        self.sign_in()
    }
    
    func sign_in(){
        //Jelly Animation required
        var signtext = "Sign In"
        let viewController : SignUpInAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpInAlertViewController") as! SignUpInAlertViewController
        
        viewController.labeltext = signtext
        viewController.segueTopicsButton.addTarget(self, action: #selector(ViewController.segue_to_onboarding), for: .touchUpInside)
        viewController.segueHomeButton.addTarget(self, action: #selector(ViewController.segue_to_home_tab), for: .touchUpInside)
        
        var midy = (self.view.frame.height / 2) - (240 / 2)
        let alertPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                         presentationCurve: .linear,
                                                         cornerRadius: 8,
                                                         backgroundStyle: .blur(effectStyle: .dark),
                                                         jellyness: .jellier,
                                                         duration: .normal,
                                                         directionShow: .top,
                                                         directionDismiss: .top,
                                                         widthForViewController: .custom(value:309),
                                                         heightForViewController: .custom(value:240),
                                                         horizontalAlignment: .center,
                                                         verticalAlignment: .top,
                                                         marginGuards: UIEdgeInsets(top: midy, left: 5, bottom: 30, right: 5))
        
        
        let presentation = alertPresentation
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: viewController)
        self.present(viewController, animated: true, completion: nil)
        
        
    }

    func segue_to_home_tab(){
        self.performSegue(withIdentifier: "go home", sender: self)
    }
    func segue_to_onboarding(){
        self.performSegue(withIdentifier: "onboarding", sender: self)
    }
    
    
    
    
    
    
    // Loading
    func start_loading(){
        var yp = view.frame.height / 2 - ((view.bounds.width) / 2) - 50
        
        var loadview = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        let undercooked_image = UIImageView(frame: CGRect(x: loadview.frame.width / 2 - 23, y: loadview.frame.height / 2 - 96, width: 45, height: 76))
        undercooked_image.contentMode = .scaleAspectFit
        undercooked_image.image = UIImage(named: "blue_u")
        
        loadview.addSubview(undercooked_image)
        let bluecolor = UIColor(red: 29/255, green: 171/255, blue: 192/255, alpha: 1)
//        let pop_red = UIColor(colorLiteralRed: 255/255, green: 103/255, blue: 102/255, alpha: 1)
        
        loadview.backgroundColor = UIColor.white
        loadview.alpha = 0
        self.view.addSubview(loadview)
        loadview.fadeIn(duration: 0.6)
        
        var delayInSeconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            var size : CGFloat = 37
            var xxp = loadview.frame.width / 2 - (size / 2)
            var hp = loadview.frame.height / 2 - (size / 2)
            let frame = CGRect(x: xxp, y: hp, width: size, height: size)
            
            self.actIndi = NVActivityIndicatorView(frame: frame, type: .lineScale, color: bluecolor, padding: 3)
            self.actIndi!.startAnimating()
            self.actIndi!.alpha = 0
            
            loadview.addSubview(self.actIndi!)
            
            self.actIndi!.fadeIn(duration: 0.2)
        }
        
        delayInSeconds = 1.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            //loadview.fadeOut(duration: 0.6)
            
        }
        
    }
    

}

