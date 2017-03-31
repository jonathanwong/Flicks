//
//  NowPlayingDetailViewController.swift
//  Flicks
//
//  Created by Jonathan Wong on 3/30/17.
//  Copyright © 2017 Jonathan Wong. All rights reserved.
//

import UIKit
import Alamofire

class NowPlayingDetailViewController: UIViewController {

    @IBOutlet weak var movieImageView: UIImageView!
    
    var currentMovie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = currentMovie.value(forKey: "title") as! String
        let overview = currentMovie.value(forKey: "overview") as! String
        let posterPath = currentMovie.value(forKey: "poster_path") as! String
        let url = URL(string: NowPlayingViewController.baseUrl + posterPath)
        let movie = Movie(title: title, description: overview, imageUrl: url)
        
        if url != nil {
            Alamofire.request(url!).responseData(completionHandler: {
                response in
                self.movieImageView.image = UIImage(data: response.data!)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
