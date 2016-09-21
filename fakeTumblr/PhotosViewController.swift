//
//  PhotosViewController.swift
//  fakeTumblr
//
//  Created by Chaitanya Pilaka on 9/19/16.
//  Copyright © 2016 Chaitanya Pilaka. All rights reserved.
//

import UIKit
import AFNetworking


class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .Gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.hidden = true
    }
    
    func startAnimating() {
        self.hidden = false
        self.activityIndicatorView.startAnimating()
    }
}



class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    

    
    @IBOutlet weak var tableView: UITableView!
   
    var posts: [NSDictionary] = []
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //tableview stuff
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 240
        
        let refreshControl = UIRefreshControl()
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        
        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                      completionHandler: { (data, response, error) in
                                                                        if let data = data {
                                                                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                                                data, options:[]) as? NSDictionary {
                                                                                print("responseDictionary: \(responseDictionary)")
                                                                                
                                                                                // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                                                                                // This is how we get the 'response' field
                                                                                let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                                                                                
                                                                                // This is where you will store the returned array of posts in your posts property
                                                                                 self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                                                                            }
                                                                              self.tableView.reloadData()
                                                                        }
        });
        task.resume()
        
        

        // Do any additional setup after loading the view.
    }
    
    
    //table view stuff
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell") as! PhotoCell
        
        
        let post = posts[indexPath.row]
        if let photos = post.valueForKeyPath("photos") as? [NSDictionary] {
         let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String
        if let imageUrl = NSURL(string: imageUrlString!){
            cell.fakeImageView.setImageWithURL(imageUrl)
        } else {
            print("Image url is null")
        }
        } else {
            print ("image url is null")
        }
        
        
        
        return cell
        
        
    }
    



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as! PhotoDetailsViewController
        var indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        
        let post = posts[indexPath!.row]
        if let photos = post.valueForKeyPath("photos") as? [NSDictionary] {
            let imageUrlString = photos[0].valueForKey("original_size.url") as? String
            if let imageUrl = NSURL(string: imageUrlString!) {
                vc.imageURL = imageUrl
            }
            if let imageCaption = post.valueForKeyPath("caption") as? String{
                vc.caption = imageCaption
            }
            else{
                print ("error")
            }
        }

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(!isMoreDataLoading) {
            
            
            
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                
                let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
                let request = NSURLRequest(URL: url!)
                let session = NSURLSession(
                    configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                    delegate:nil,
                    delegateQueue:NSOperationQueue.mainQueue()
                )
                
                
                let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                              completionHandler: { (data, response, error) in
                                                                                
                                                                                // Update flag
                                                                                self.isMoreDataLoading = false
                                                                                
                                                                                // Stop the loading indicator
                                                                                self.loadingMoreView!.stopAnimating()
                                                                                
                                                                                if let data = data {
                                                                                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                                                        data, options:[]) as? NSDictionary {
                                                                                        print("responseDictionary: \(responseDictionary)")
                                                                                        
                                                                                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                                                                                        // This is how we get the 'response' field
                                                                                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                                                                                        
                                                                                        // This is where you will store the returned array of posts in your posts property
                                                                                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                                                                                        self.tableView.reloadData()
                                                                                        
                                                                                    }
                                                                                }
                });
                task.resume()
                
                
            }
            
            
        }
    }
    
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
                                                                      completionHandler: { (data, response, error) in
                                                                        
                                                                        // Update flag
                                                                        self.isMoreDataLoading = false
                                                                        
                                                                        // Stop the loading indicator
                                                                        self.loadingMoreView!.stopAnimating()
                                                                        
                                                                        // ... Use the new data to update the data source ...
                                                                        
                                                                        // Reload the tableView now that there is new data
                                                                        self.myTableView.reloadData()
        });
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

}
