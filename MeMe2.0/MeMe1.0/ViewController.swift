//
//  ViewController.swift
//  MeMe1.0
//
//  Created by Tristan Pudell-Spatscheck on 2/19/19.
//  Copyright © 2019 TAPS. All rights reserved.
//
import Foundation
import UIKit
//THIS IS THE MEME EDITOR VIEW CONTROLLER
class ViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    //default text attributes
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0
    ]
    //Sets up button+stuff (iboutlet)
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var bottomField: UITextField!
    @IBOutlet weak var topField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var share: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var toolBar: UIToolbar!
    //checks to see if text being used should make the keyboard move
    var activeText = false
    //index of meme
    var index:  Int!
    //boolean to see if it comes from edit
    var editting = false
    //sets up memes array properly
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    //Abstract toolbar hider class
    func showBar(_ hide: Bool) {
        toolBar.isHidden = hide
        navBar.isHidden = hide
    }
    //Abstract default text setup class
    func configure(_ textField: UITextField, with defaultText: String) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.textAlignment = .center
    }
    //Abstract image picker class
    func pickAnImage(from source: UIImagePickerController.SourceType) {
        share.isEnabled=true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    //picks image from album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(from: .photoLibrary)
    }
    //picks image from camera
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(from: .camera)
    }
    //sets image in background of meme
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = image
        }
        else{
            print("Invalid Photo Error")
        }
        self.dismiss(animated: true, completion: nil)
    }
    //clears text when clicked the first time
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField==topField && topField.text=="TOP"){
            topField.text=""
        }
        if(textField==bottomField && bottomField.text=="BOTTOM"){
            bottomField.text=""
       }
        //sets activeText to true if the bottomField is being typed in
        if(textField==bottomField){
            activeText=true
        }
    }
    //dismisses view controllers when cancel is clicked
    @IBAction func cancelButton(_ sender: Any){
        imageView.image = UIImage(named: "default")
        share.isEnabled = false
        dismiss(animated: true, completion: nil)
    }
    //makes share button work
    @IBAction func shareButton(_ sender: Any){
        if(share.isEnabled==true){
        let memedImage = generateMemedImage()
            let activityVC = UIActivityViewController(activityItems: [memedImage as Any], applicationActivities: nil)
          //the completionwithitmeshandler SAVES shared images
            activityVC.completionWithItemsHandler = {(_,success,_,error) in
                if(success && error == nil){
                    self.save()
                    self.dismiss(animated: true, completion: nil)
                }
                else if (error != nil){
                }
            }
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if(editting){
            let meme = memes[index]
            topField.text = meme.topText
            bottomField.text = meme.bottomText
            configure(topField, with: topField.text!)
            configure(bottomField, with: bottomField.text!)
            imageView.image = meme.image
            editting = false
        }
        else {
        //disables share button until imague is picked
        share.isEnabled=false
        //sets up text allignment
        configure(topField, with: topField.text!)
        configure(bottomField, with: bottomField.text!)
        //sets background image
        imageView.image = UIImage(named: "default")
        }
    }
    //makes keyboard go back down after hitting return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //sets activeText to false once typing is done
        textField.resignFirstResponder()
        return true
    }
    //what happens when keyboard appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //checks if there is a camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        //sets up keybaord stuff
        subscribeToKeyboardNotifications()
    }
    //what happens when keyboard dissapears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //sets up keyboard stuff
        unsubscribeFromKeyboardNotifications()
    }
    //tells you when keyboard is being used
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //tells you when keyboard isn't being used
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //when keyboard is being shown, sets keyboard hight
    @objc func keyboardWillShow(_ notification:Notification) {
        if(activeText){
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification){
        if(activeText){
        view.frame.origin.y = 0
        //makes activeText false once done typing in bottom text
        activeText=false
        }
    }
    //finds out what high the keyboard should be at
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    //generates meme
    func generateMemedImage() -> UIImage {
        //hides toolbal/navbar
        showBar(true)
        ///renders meme
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //shows toolbal/navbar
        showBar(false)
        return memedImage
    }
    //saves meme
    func save() {
        let memedImage = generateMemedImage()
        // Create the meme
        let meme = Meme(topText: topField.text!, bottomText: bottomField.text!, image: imageView.image!, meme: memedImage)
        //adds meme to appDelegate ( for app-wide access)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
}
