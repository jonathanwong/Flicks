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
    @IBOutlet weak var nowPlayingCollectionView: UICollectionView!
    
    var endpoint: String?
    var movieResults: [NSDictionary] = []
    static let baseUrl = "https://image.tmdb.org/t/p/w342"
    static let baseUrlSmall = "https://image.tmdb.org/t/p/w92"
    var selectedMovieDictionary: NSDictionary?
    var networkErrorView: UIView!
    var toggleViewButton: UIBarButtonItem!
    var isTableVisible = true
    var filteredMovies: [NSDictionary] = []
    var searchCtrl: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMovies(completion: nil)
        
        nowPlayingTableView.rowHeight = 150
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.refreshMovies(_:)), for: .valueChanged)
        nowPlayingTableView.insertSubview(refreshControl, at: 0)
        
        toggleViewButton = UIBarButtonItem(title: "Col", style: .plain, target: self, action: #selector(NowPlayingViewController.toggleView(_:)))
        self.navigationItem.rightBarButtonItem = toggleViewButton
        
        let searchController = UISearchController(searchResultsController: nil)
        searchCtrl = searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
//        nowPlayingTableView.tableHeaderView = searchController.searchBar  // not working
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
        
        let collectionViewWidth = nowPlayingCollectionView.frame.width / 3
        let layout = nowPlayingCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: collectionViewWidth, height: collectionViewWidth)
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
                    self.nowPlayingCollectionView.reloadData()
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
    
    func toggleView(_ sender: UIBarButtonItem) {
        isTableVisible = !isTableVisible
        
        if (isTableVisible) {
            toggleViewButton.title = "Col"
            
            self.nowPlayingTableView.isHidden = false
            UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseInOut, animations: {
                self.nowPlayingTableView.alpha = 1.0
            }, completion: {
                (value: Bool) in
                UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseInOut, animations: {
                    self.nowPlayingCollectionView.alpha = 0.0
                }, completion: {
                    (value: Bool) in
                    self.nowPlayingCollectionView.isHidden = true
                })
            })
        } else {
            toggleViewButton.title = "Tab"
            
            self.nowPlayingCollectionView.isHidden = false
            UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseInOut, animations: {
                self.nowPlayingCollectionView.alpha = 1.0
            }, completion: {
                (value: Bool) in
                UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseInOut, animations: {
                    self.nowPlayingTableView.alpha = 0.0
                }, completion: {
                    (value: Bool) in
                    self.nowPlayingTableView.isHidden = true
                })
            })
        }
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
        } else if segue.identifier == "collectionViewToDetail" {
            if let indexPath = nowPlayingCollectionView!.indexPathsForSelectedItems!.first! as? IndexPath {
                let destination = segue.destination as! NowPlayingDetailViewController
                 destination.currentMovie = movieResults[indexPath.row]
            }
        }
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredMovies = movieResults.filter { movie in
            return (movie.value(forKey: "title") as! String).lowercased().contains(searchText.lowercased())
        }
        
        nowPlayingTableView.reloadData()
    }
}

extension NowPlayingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension NowPlayingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchCtrl.isActive && searchCtrl.searchBar.text != "" {
            return filteredMovies.count
        }
        return movieResults.count
    }
    
    func movie(for indexPath: IndexPath) -> Movie {
        let currentMovie = movieResults[indexPath.row]
        let title = currentMovie.value(forKey: "title") as! String
        let overview = currentMovie.value(forKey: "overview") as! String
        let posterPath = currentMovie.value(forKey: "poster_path") as! String
        let url = URL(string: NowPlayingViewController.baseUrl + posterPath)
        let movie = Movie(title: title, description: overview, imageUrl: url)
        
        return movie
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NowPlayingTableViewCell", for: indexPath) as! NowPlayingTableViewCell
        var currentMovie = NSDictionary()
        if searchCtrl.isActive && searchCtrl.searchBar.text != "" {
            currentMovie = filteredMovies[indexPath.row]
        } else {
            currentMovie = movieResults[indexPath.row]
        }
        let title = currentMovie.value(forKey: "title") as! String
        let overview = currentMovie.value(forKey: "overview") as! String
        let posterPath = currentMovie.value(forKey: "poster_path") as! String
        let url = URL(string: NowPlayingViewController.baseUrl + posterPath)
        let movie = Movie(title: title, description: overview, imageUrl: url)
        cell.movie = movie
        cell.movieImageView.alpha = 0.0
        
        if url != nil {
            Alamofire.request(url!).responseData(completionHandler: {
                response in
                cell.movieImageView.image = UIImage(data: response.data!)
                UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
                    cell.movieImageView.alpha = 1.0
                }, completion: nil)
            })
        }
        
        return cell
    }
}

extension NowPlayingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchCtrl.isActive && searchCtrl.searchBar.text != "" {
            selectedMovieDictionary = filteredMovies[indexPath.row]
        } else {
            selectedMovieDictionary = movieResults[indexPath.row]
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        let backgroundView = UIView(frame: (cell?.contentView.frame)!)
        backgroundView.layer.cornerRadius = 20.0
        backgroundView.backgroundColor = UIColor.gray
        cell?.selectedBackgroundView = backgroundView
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showNowPlayingDetailViewController", sender: self)
    }
}

extension NowPlayingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let m = movie(for: indexPath)
        
        if m.imageUrl != nil {
            Alamofire.request(m.imageUrl!).responseData(completionHandler: {
                response in
                cell.movieImageView.image = UIImage(data: response.data!)
                UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseInOut, animations: {
                    cell.movieImageView.alpha = 1.0
                }, completion: nil)
            })
        }
        
        return cell
    }
}
