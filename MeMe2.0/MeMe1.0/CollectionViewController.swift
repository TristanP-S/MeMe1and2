//
//  CollectionViewController.swift
//  MeMe1.0
//
//  Created by Tristan Pudell-Spatscheck on 3/7/19.
//  Copyright © 2019 TAPS. All rights reserved.
//
import UIKit
import Foundation
class CollectionViewController: UICollectionViewController{
    //impots meme index
    var index:  Int!
    //imports the memes to this class
    var memes: [Meme]! {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    //finds amount of views
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        //finds meme image
        let meme = self.memes[(indexPath as NSIndexPath).row]
        // Set the image
        cell.memePic.image = meme.meme
        return cell
    }
    //reloads photos stored in app every time grid appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }
    //makes imageview do something when tapped, in this case push the DetailedView
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailedViewController") as! DetailedViewController
        vc.index = indexPath.item
        navigationController?.pushViewController(vc, animated: true)
    }
}
