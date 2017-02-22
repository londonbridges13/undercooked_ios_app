//
//  ArticleViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/3/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import AMScrollingNavbar
import WebKit
import Alamofire
import RealmSwift
import FaveButton

func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}

class ArticleViewController: ScrollingNavigationViewController, UIWebViewDelegate, FaveButtonDelegate {

    @IBOutlet var bottomView : UIView!
    @IBOutlet var likeButton : FaveButton!
    @IBOutlet var likeCountLabel : UILabel!
    @IBOutlet var shareButton : UIButton!
    @IBOutlet var navButton : UIButton!
    @IBOutlet var backButton : UIButton!
    @IBOutlet weak var webV: UIWebView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var unwind_homeVC_button : UIButton!
    @IBOutlet var unwind_proVC_button : UIButton!

    var lastOffsetY :CGFloat = 0
    var article_url : String?
    var article : Article?
    var action: String?
    var like_count: Int?
    
//    let colors = [
//        DotColors(first: color(0x7DC2F4), second: color(0xE2264D)),
//        DotColors(first: color(0xF8CC61), second: color(0x9BDFBA)),
//        DotColors(first: color(0xAF90F4), second: color(0x90D1F9)),
//        DotColors(first: color(0xE9A966), second: color(0xF8C852)),
//        DotColors(first: color(0xF68FA7), second: color(0xF6A2B8))
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.likeCountLabel.text = ""
        self.progressView.progress = 0.0
        self.progressView.trackTintColor = UIColor.clear
        let yourBackImage = UIImage(named: "back_button_image")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.backItem?.title = "Custom"
        self.shareButton.addTarget(self, action: #selector(ArticleViewController.share_article), for: .touchUpInside)
        webV.scrollView.delegate = self
        webV.delegate = self
        let url = article_url!
        print(article_url!)
        let requestURL = URL(string:url)
        let request = URLRequest(url: requestURL!)
        webV.loadRequest(request as URLRequest)
        
        var adelayInSeconds = 0.325
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            self.progressView.setProgress(0.15, animated: true)
        }
        adelayInSeconds = 0.43
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            self.progressView.setProgress(0.45, animated: true)
        }
        adelayInSeconds = 0.22
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            self.progressView.setProgress(0.65, animated: true)
        }
        
        if action == "profile"{
            // came from profile View Controller, unwind using unwind_proVC_button
            self.backButton.addTarget(self, action: #selector(ArticleViewController.unwind_profile), for: .touchUpInside)
        }else{
            // came from home tab
            self.backButton.addTarget(self, action: #selector(ArticleViewController.unwind_home), for: .touchUpInside)
        }
        
        self.likeButton.setTitle("", for: .normal)
        self.likeButton.delegate = self
        self.likeButton.normalColor = UIColor.white
        self.likeButton.selectedColor = UIColor(colorLiteralRed: 226/255, green: 38/255, blue: 77/255, alpha: 1)
        self.likeButton.isSelected = false
        if self.article != nil{
            get_article_likes()
            did_user_like_article()
            self.likeButton.addTarget(self, action: #selector(ArticleViewController.like_article), for: .touchUpInside)
        }
//        let options = [UIApplicationOpenURLOptionUniversalLinksOnly : true]
//        UIApplication.shared.open(url, options: options, completionHandler: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(webV.scrollView, delay: 0.0)
        }
        
    }

    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool){
    }
    
//    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
//        if (faveButton === likeButton){
//            return colors
//        }
//        return nil
//    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
       
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        self.progressView.setProgress(1.0, animated: true)
        self.progressView.fadeOut()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        self.progressView.setProgress(1.0, animated: true)
        self.progressView.fadeOut()
    }
    
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self.view)
            print(position.x)
            print(position.y)
        }
        print("doesn't work")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrolling")
        
        if self.webV.scrollView.panGestureRecognizer.translation(in: self.webV).y < 0.0{
            var offset = self.webV.scrollView.panGestureRecognizer.translation(in: self.webV).y
            if offset > 0{
                offset = offset * -1
            }
            let up = CGAffineTransform(translationX: 0, y: -1 * (offset))
            UIView.animate(withDuration: 0.600, animations: {
                self.bottomView?.transform = up
            })
        }else{
            var offset = self.webV.scrollView.panGestureRecognizer.translation(in: self.webV).y
            if offset > 0{
                offset = offset * -1
            }
            let up = CGAffineTransform(translationX: 0, y: 0)
            UIView.animate(withDuration: 0.600, animations: {
                self.bottomView?.transform = up
            })
        }
    }
    
    
    func scrollingNavigationController(_ controller: ScrollingNavigationController, didChangeState state: NavigationBarState) {
        
        switch state {
        case .collapsed:
            print("navbar collapsed")
            var offset = self.webV.scrollView.panGestureRecognizer.translation(in: self.webV).y
            if offset > 0 {
                offset = offset * -1
            }
            let down = CGAffineTransform(translationX: 0, y: -1 * (offset))
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomView?.transform = down
            })
        case .expanded:
            print("navbar expanded")
            var offset = self.webV.scrollView.panGestureRecognizer.translation(in: self.webV).y
            if offset > 0 {
                offset = offset * -1
            }
            let down = CGAffineTransform(translationX: 0, y:  -1 * (offset))
            
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomView?.transform = down
            })
            
        case .scrolling:
            print("navbar is moving")
        }
    }

    
    func like_article(){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uarticle" : article!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/articles/like_an_article", method: .post, parameters: parameters).responseJSON { (response) in
                if let count = response.result.value as? Int{
                    if count != 0{
                        self.likeCountLabel.text = " \(count)"
                    }
                    print(response.result.value)
                }
            }
        }

    }
    
    func get_article_likes(){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uarticle" : article!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/articles/get_article_like_count", method: .post, parameters: parameters).responseJSON { (response) in
                if let count = response.result.value as? Int{
                    if count != 0{
                        self.likeCountLabel.text = " \(count)"
                    }
                    print(response.result.value)
                }
            }
        }
        
    }
    
    func did_user_like_article(){
        print("starting did_user_like_article")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uarticle" : article!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/did_user_like_article", method: .post, parameters: parameters).responseJSON { (response) in
                print("Result: \(response.result.value)")
                if let result = response.result.value as? Bool{
                    if result == true{
                        print("true, button state is now selected")
                        // user already liked this. Set button as selected
                        self.likeButton.isSelected = true

                        
                    }else{
                        print("false or nothing")
                        // user didn't like article, or error
                        //do nothing
                    }
                    print("done did_user_like_article")
                }
            }
        }

    }
    
    
    func share_article(){
        print("Displaying UIActivity Controller")
        let textToShare = "\(self.article!.title!)\n"
        
        if let myWebsite = NSURL(string: "\(self.article_url!)") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    func unwind_home(){
        unwind_homeVC_button.sendActions(for: .touchUpInside)
    }
    
    func unwind_profile(){
        unwind_proVC_button.sendActions(for: .touchUpInside)
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
