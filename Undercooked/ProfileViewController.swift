//
//  ProfileViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/4/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import Jelly
import Kingfisher

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableview: UITableView!
    
    var profile_pic : UIImage?
    var profile_pic_url : String?
    var username : String?
    var results = [Searchable]() // All Results, Products, Articles, Ads, Promotions
    var selected_article_url : String?
    var selected_article : Article?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        tableview.delegate = self
        tableview.dataSource = self
        get_saved_articles()

        
//        update_profile_pic(image: UIImage(named: "ExploreImage")!)
//        check_for_profile_pic()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        check_for_profile_pic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count + 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            // Display Profile Cell
            let cell : ProfileCell = tableview.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            
            cell.backView.layer.cornerRadius = 6
            cell.lowerView.layer.cornerRadius = 6
            cell.topicsButton.layer.cornerRadius = 4
            cell.topicsButton.layer.borderColor = cell.topicsButton.titleColor(for: .normal)?.cgColor
            cell.topicsButton.layer.borderWidth = 1
            cell.profileBackView.layer.cornerRadius = 6
            cell.profileImageView.layer.cornerRadius = 4
            
            cell.profileBackView.layer.shadowColor = UIColor.black.cgColor
            cell.profileBackView.layer.shadowOpacity = 0.6
            cell.profileBackView.layer.shadowOffset = CGSize(width: 0, height: 1.7)
            cell.profileBackView.layer.shadowRadius = 2
            
            cell.backView.layer.shadowColor = UIColor.darkGray.cgColor
            cell.backView.layer.shadowOpacity = 0.6
            cell.backView.layer.shadowOffset = CGSize(width: 0, height: 1.7)
            cell.backView.layer.shadowRadius = 2
            
            cell.settingsButton.addTarget(self, action: #selector(ProfileViewController.segue_to_settings), for: .touchUpInside)
            if self.profile_pic_url != nil{
                cell.download_image(image_url: self.profile_pic_url!)
            }
            if self.username != nil{
                cell.nameLabel.text = username!
            }else{
                cell.nameLabel.text = ""
            }
            return cell
        }else if indexPath.row == 1{
            // Display Article's you've liked
            let cell = tableview.dequeueReusableCell(withIdentifier: "pre article cell", for: indexPath)
            return cell
            
        }else{
            // Display Article Cell
            let indexx = indexPath.row - 2
            let cell : ArticleCell = tableview.dequeueReusableCell(withIdentifier: "ArticleCellInProduct", for: indexPath) as! ArticleCell
            if results[indexx].article != nil{
                if results[indexx].article!.title != nil{
                    cell.titleLabel.text = results[indexx].article!.title!
                }
                if results[indexx].article!.desc != nil{
                    cell.descLabel.text = results[indexx].article!.desc!
                }
                if results[indexx].article!.resource_title != nil{
                    cell.resourceLabel.text = results[indexx].article!.resource_title!
                }
                if results[indexx].article!.article_image_url != nil{
                    cell.get_article_image(url: results[indexx].article!.article_image_url!)
                    cell.articleImageView.backgroundColor = UIColor.clear
                }
            }
            cell.topicLabel.text = "Saved"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            // ProfileCell Height
            return 229
        }else if indexPath.row == 1{
            //Article's you've liked Height
            return 66
        }else{
            // Article Cell Height
            return 218
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexx = indexPath.row - 2

        tableview.deselectRow(at: indexPath, animated: true)
        if indexPath.row > 1{
            // display article
            self.selected_article = results[indexx].article!

            visit_article(url: results[indexx].article!.article_url!)
        }
    }
    
    func check_for_profile_pic(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil{
            if user!.profile_pic?.length != nil{
                print(user!.profile_pic?.length)
                self.profile_pic = UIImage(data: user!.profile_pic as! Data)
            }else{
                // Query for a picture
                self.get_profile_pic()
            }
            if user!.name != nil{
                self.username = user!.name!
            }else{
                //get user name
                self.get_username()
            }
        }
    }
    
    func get_profile_pic(){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/profile_pic", method: .post, parameters: parameters).responseJSON { (response) in
//                print(response.result.value!)
                self.profile_pic_url = "\(response.result.value!)" // changed for amazon
                print(self.profile_pic_url)
                self.tableview.reloadData()
                print("done")
            }
        }

    }
    
    func update_profile_pic(image : UIImage){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let data = UIImagePNGRepresentation(UIImage(named: "back_button_image")!) as NSData!
            print(UIImage(named: "back_button_image")!)
            print("")
            let pic : Data = UIImageJPEGRepresentation(image, 1)!
            let pic_b64 = pic.base64EncodedString()
            
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "photo_path": "data:image/jpeg;base64,\(pic_b64)"

            ]
            let URL = try! URLRequest(url: "https://secret-citadel-33642.herokuapp.com/api/v1/users/update_profile_pic", method: .post)
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    print("pic_b64 : \(pic_b64)")
                    for (key, value) in parameters {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
            },
                with: URL,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            print(response.result.value)
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                    }
            }
            )
            
        }
        
    }

    
    
    func get_username(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/profile", method: .post, parameters: parameters).responseJSON { (response) in
                //                print(response.result.value!)
                if let result = response.result.value as? NSDictionary{
                    var name = result["name"] as? String
                    if name != nil{
                        self.username = name!
                    }
                    self.tableview.reloadData()
                    print(response.result.value!)
                    print("done getting username")
                }
            }
        }
    }
    
    
    
    func get_saved_articles(){
        self.results.removeAll()
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/articles/likedarticles", method: .post, parameters: parameters).responseJSON { (response) in
                if let articles = response.result.value as? NSArray{
                    for each in articles{
                        if let article = each as? NSDictionary{
                            // Inside Article
                            var a = Article()
                            var id = article["id"] as? Int
                            if id != nil{
                                a.id = id!
                            }
                            var title = article["title"] as? String
                            if title != nil{
                                a.title = title!
                            }
                            var desc = article["desc"] as? String
                            if desc != nil{
                                a.desc = desc!
                            }
                            var article_image_url = article["article_image_url"] as? String
                            if article_image_url != nil{
                                a.article_image_url = "\(article_image_url!)"
                            }
                            var article_url = article["article_url"] as? String
                            if article_url != nil{
                                a.article_url = "\(article_url!)"
                            }
//                            self.articles.append(a)
                            var result = Searchable()
                            result.article = a
                            self.get_article_resource(article: result)
                            print(a.desc)
                            print("\(self.results.count)")
                            self.tableview.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    func get_article_resource(article : Searchable){
        print("starting get_article_resource ...")
        // sets the resource for the article, for user to know where article came from
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uarticle": article.article!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/resources/get_resource", method: .post, parameters: parameters).responseJSON { (response) in
                //                print(response.result.value!)
                var resource = "https://secret-citadel-33642.herokuapp.com\(response.result.value!)"
                print(resource)//https://secret-citadel-33642.herokuapp.com
                
                resource = (resource as NSString).replacingOccurrences(of: "https://secret-citadel-33642.herokuapp.com", with: "")
                
                article.article?.resource_title = resource
                self.results.append(article)
                self.tableview.reloadData()
                print("done -- get_article_resource")
            }
        }
    }
    
    func pull_to_refresh(){
        self.results.removeAll()
        self.get_saved_articles()
    }

    func visit_article(url : String){
        self.selected_article_url = url
        
        segue_to_article()
    }
    
    func segue_to_article(){
        self.performSegue(withIdentifier: "p_a", sender: self)
    }

    func segue_to_settings(){
        self.performSegue(withIdentifier: "p_s", sender: self)
    }
    
    @IBAction func unwind_to_profileVC(segue : UIStoryboardSegue){
        
//        self.results.removeAll()
//        get_saved_articles()

    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "p_a"{
            let vc : ArticleViewController = segue.destination as! ArticleViewController
            vc.article_url = selected_article_url!
            vc.action = "profile"
            vc.article = self.selected_article

        }else if segue.identifier == "p_s"{
//            let vc : SettingsViewController = segue.destination as! SettingsViewController
            
        }
    }
    

}
