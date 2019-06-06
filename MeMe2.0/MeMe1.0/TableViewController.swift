//
//  TableViewController.swift
//  MeMe1.0
//
//  Created by Tristan Pudell-Spatscheck on 3/7/19.
//  Copyright © 2019 TAPS. All rights reserved.
//
import UIKit
import Foundation
class TableViewController: UITableViewController{
    @IBOutlet var tablView: UITableView!
    //imports memes to this class
    var memes: [Meme]! {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    //finds amount of views
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    //sets up each table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        //finds meme object
        let meme = self.memes[(indexPath as NSIndexPath).row]
        // Set the text and image
        cell.memePic.image = meme.meme
        cell.memeText.text = meme.topText + "..." + meme.bottomText
        return cell
    }
    //reloads photos stored in app every time table appears
    override func viewWillAppear(_ animated: Bool) {
        tablView.reloadData()
    }
    //makes imageview do something when tapped, in this case push the DetailedView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailedViewController") as! DetailedViewController
        vc.index = indexPath.item
        navigationController?.pushViewController(vc, animated: true)
    }
}
