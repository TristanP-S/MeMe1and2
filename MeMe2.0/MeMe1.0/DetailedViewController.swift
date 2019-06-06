//
//  DetailedViewController.swift
//  MeMe1.0
//
//  Created by Tristan Pudell-Spatscheck on 3/7/19.
//  Copyright © 2019 TAPS. All rights reserved.
//
import UIKit
import Foundation
class DetailedViewController: UIViewController {
    @IBOutlet weak var memePic: UIImageView!
    //impots meme index
    var index:  Int!
    //imports the memes to this class
    var memes: [Meme]! {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    //makes edit button work
    @objc func editTapped(_ sender: Any) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "photoEdit") as! ViewController
        vc.index = index
        vc.editting = true
        self.dismiss(animated: true, completion: nil)
        present(vc, animated: true)
    }
    //sets image of DetailedViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //sets up Edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped(_:)))
        let meme = memes[index]
        memePic.image = meme.image
    }
    
}
