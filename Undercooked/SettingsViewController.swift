//
//  SettingsViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 1/5/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Jelly
import NVActivityIndicatorView
import RealmSwift
import Alamofire
import Kingfisher


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet var tableview: UITableView!
    
    var loadview : UIView?
    var actIndi : NVActivityIndicatorView?
    var options = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        tableview.delegate = self
        tableview.dataSource = self
        
        self.options.append("Share Undercooked 👌")
        self.options.append("Change Name")
        self.options.append("Update Profile Picture")
        self.options.append("Change Password")
        self.tableview.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "settingscell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0{
            // invite user
            self.invite_other()
        }else if indexPath.row == 1{
            self.go_change_name()
        }else if indexPath.row == 2{
            self.select_new_image()
        }else{
            self.go_change_password()
        }
    }

    func invite_other(){
        print("Displaying UIActivity Controller")
        let textToShare = "I know how much you love food, check out Undercooked"
        
        if let myWebsite = NSURL(string: "") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    func update_profile_pic(image : UIImage){
        start_loading()
        
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
                            self.end_loading()
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        self.end_loading()
                    }
            }
            )
            
        }
        
    }
    

    func select_new_image(){
        let actionSheetController: UIAlertController = UIAlertController(title: "Select Option", message: "", preferredStyle: .actionSheet)
        
        
        let cameraActionButton: UIAlertAction = UIAlertAction(title: "Use Camera", style: .default)
        { action -> Void in
            print("Opening")
            self.open_camera()
        }
        actionSheetController.addAction(cameraActionButton)
        
        let libraryActionButton: UIAlertAction = UIAlertAction(title: "Open Photo Library", style: .default)
        { action -> Void in
            print("Opening")
            self.open_library()
        }
        actionSheetController.addAction(libraryActionButton)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)

        self.present(actionSheetController, animated: true, completion: nil)
    }
    func open_camera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func open_library(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        self.update_profile_pic(image: selectedImage)
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //Loading, for uploading image
    
    func start_loading(){
        UIApplication.shared.beginIgnoringInteractionEvents()
        var yp = view.frame.height / 2 - (180 / 2)
        var xp = view.frame.width / 2 - (270 / 2)
        
        loadview = UIView(frame: CGRect(x: xp, y: yp, width: 270, height: 180))
        
        let loadLabel = UILabel(frame: CGRect(x: 0, y: 15, width: (loadview?.frame.width)!, height: 45))
        loadLabel.textColor = UIColor.white
        loadLabel.textAlignment = .center
        loadLabel.font = UIFont(name: "SanchezSlab", size: 35)
        loadLabel.adjustsFontSizeToFitWidth = true
        loadLabel.minimumScaleFactor = 0.1
        loadLabel.text = "Uploading"
        loadview?.addSubview(loadLabel)
        
        
        let pop_red = UIColor(colorLiteralRed: 255/255, green: 103/255, blue: 102/255, alpha: 1)
        
        loadview?.backgroundColor = pop_red
        loadview?.layer.cornerRadius = 5
        loadview?.alpha = 0
        self.view.addSubview(self.loadview!)
        loadview?.fadeIn(duration: 0.6)
        
        var delayInSeconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            var size : CGFloat = 37
            var xxp = (self.loadview?.frame.width)! / 2 - (size / 2)
            var hp = (self.loadview?.frame.height)! / 2 - (size / 2)
            let frame = CGRect(x: xxp, y: hp, width: size, height: size)
            
            self.actIndi = NVActivityIndicatorView(frame: frame, type: .lineScale, color: UIColor.white, padding: 3)
            self.actIndi?.startAnimating()
            self.actIndi?.alpha = 0
            
            self.loadview?.addSubview(self.actIndi!)
            
            self.actIndi?.fadeIn(duration: 0.2)
        }
        
//        delayInSeconds = 1.25
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
//            loadview.fadeOut(duration: 0.6)
//            self.tableview.reloadData()
//        }
        
    }
    
    func end_loading(){
        UIApplication.shared.endIgnoringInteractionEvents()
        let delayInSeconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.loadview?.fadeOut(duration: 0.6)
            self.tableview.reloadData()
        }
    }
    
    
    

    func go_change_password(){
        performSegue(withIdentifier: "changepassword", sender: self)
    }
    
    func go_change_name(){
        performSegue(withIdentifier: "changename", sender: self)
    }
    
    @IBAction func unwind_to_settings(segue: UIStoryboardSegue){
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "changepassword"{
            let vc : ChangePasswordViewController = segue.destination as! ChangePasswordViewController
        }
    }
    

}
