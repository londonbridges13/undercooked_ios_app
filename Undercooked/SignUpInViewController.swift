//
//  SignUpInViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/30/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Jelly

class SignUpInViewController: UIViewController {

    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    
    var jellyAnimator: JellyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signInButton.layer.cornerRadius = 4
        self.signUpButton.layer.cornerRadius = 4
        self.signInButton.layer.borderColor = UIColor.gray.cgColor
        self.signUpButton.layer.borderColor = UIColor.gray.cgColor
        self.signUpButton.layer.borderWidth = 1.25
        self.signInButton.layer.borderWidth = 1.25
        
        self.signUpButton.addTarget(self, action: "sign_up", for: .touchUpInside)
        self.signInButton.addTarget(self, action: "sign_in", for: .touchUpInside)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sign_up(){
        //Jelly Animation required
        var signtext = "Sign Up"
        let viewController : SignUpInAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpInAlertViewController") as! SignUpInAlertViewController
        viewController.labeltext = signtext
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
    
    func sign_in(){
        //Jelly Animation required
        var signtext = "Sign In"
        let viewController : SignUpInAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpInAlertViewController") as! SignUpInAlertViewController
        
        viewController.labeltext = signtext
        viewController.segueTopicsButton.addTarget(self, action: #selector(SignUpInViewController.segue_to_select_topics), for: .touchUpInside)
        viewController.segueHomeButton.addTarget(self, action: #selector(SignUpInViewController.segue_to_home_tab), for: .touchUpInside)

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
        self.performSegue(withIdentifier: "to home tab", sender: self)
    }

    func segue_to_select_topics(){
        self.performSegue(withIdentifier: "select topics", sender: self)
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
