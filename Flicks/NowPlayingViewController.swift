//
//  NowPlayingViewController.swift
//  Flicks
//
//  Created by Jonathan Wong on 3/29/17.
//  Copyright © 2017 Jonathan Wong. All rights reserved.
//

import UIKit
import Alamofire

class NowPlayingViewController: UIViewController {

    @IBOutlet weak var nowPlayingTableView: UITableView!
    
    var endpoint: String?
    var movieResults: [NSDictionary] = []
    static let baseUrl = "https://image.tmdb.org/t/p/w342"
    var selectedMovieDictionary: NSDictionary?
    var networkErrorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMovies(completion: nil)
        
        nowPlayingTableView.rowHeight = 150
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.refreshMovies(_:)), for: .valueChanged)
        nowPlayingTableView.insertSubview(refreshControl, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        networkErrorView = UIView(frame: .zero)
        let viewsDictionary: [String: UIView] = ["networkErrorView": networkErrorView]
        view.addSubview(networkErrorView)
        networkErrorView.translatesAutoresizingMaskIntoConstraints = false
        networkErrorView.alpha = 0.0
        networkErrorView.layer.backgroundColor = UIColor.gray.cgColor
        var allConstraints = [NSLayoutConstraint]()
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[networkErrorView]|", options: [], metrics: nil, views: viewsDictionary)
        NSLayoutConstraint.activate(allConstraints)
        NSLayoutConstraint(item: networkErrorView, attribute: .top, relatedBy: .equal, toItem: navigationController?.navigationBar, attribute: .bottom, multiplier: 1, constant: 0.0).isActive = true
        NSLayoutConstraint(item: networkErrorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30).isActive = true
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Network Error"
        label.textColor = UIColor.white
        networkErrorView.addSubview(label)
        NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: networkErrorView, attribute: .centerX, multiplier: 1, constant: 0.0).isActive = true
        NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: networkErrorView, attribute: .centerY, multiplier: 1, constant: 0.0).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showNetworkError(show: Bool) {
        let alpha: CGFloat = show ? 0.8 : 0.0
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.networkErrorView.alpha = alpha
        }, completion: nil)
    }
    
    func getMovies(completion: (() -> ())?) {
        SVProgressHUD.show()
        Alamofire.request("https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed").responseJSON {
            response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    self.movieResults = json["results"] as! [NSDictionary]
                    self.nowPlayingTableView.reloadData()
                }
            case .failure(let error):
                print(error)
                self.showNetworkError(show: true)
            }
            
            SVProgressHUD.dismiss()
            if completion != nil {
                completion!()
            }
        }
    }
    
    func refreshMovies(_ sender: UIRefreshControl) {
        self.getMovies(completion: {
            sender.endRefreshing()
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNowPlayingDetailViewController" {
            let destination = segue.destination as! NowPlayingDetailViewController
            
            guard selectedMovieDictionary != nil else {
                return
            }
            destination.currentMovie = selectedMovieDictionary
        }
    }
}

extension NowPlayingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NowPlayingTableViewCell", for: indexPath) as! NowPlayingTableViewCell
        let currentMovie = movieResults[indexPath.row]
        let title = currentMovie.value(forKey: "title") as! String
        let overview = currentMovie.value(forKey: "overview") as! String
        let posterPath = currentMovie.value(forKey: "poster_path") as! String
        let url = URL(string: NowPlayingViewController.baseUrl + posterPath)
        let movie = Movie(title: title, description: overview, imageUrl: url)
        cell.movie = movie
        
        if url != nil {
            Alamofire.request(url!).responseData(completionHandler: {
                response in
                cell.movieImageView.image = UIImage(data: response.data!)
            })
        }
        
        return cell
    }
}

extension NowPlayingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovieDictionary = movieResults[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showNowPlayingDetailViewController", sender: tableView.self)
    }
}
