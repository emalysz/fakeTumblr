//
//  PhotoDetailsViewController.swift
//  fakeTumblr
//
//  Created by Chaitanya Pilaka on 9/19/16.
//  Copyright © 2016 Chaitanya Pilaka. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image : UIImage!
    var imageUrl: NSURL!
    var caption: String!
    
    
    @IBOutlet weak var captionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        imageView.setImageWithURL(imageUrl)
        print(caption)
        captionLabel.text = caption

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
