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
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = currentMovie.value(forKey: "title") as! String
        let overview = currentMovie.value(forKey: "overview") as! String
        let posterPath = currentMovie.value(forKey: "poster_path") as! String
        let url = URL(string: NowPlayingViewController.baseUrl + posterPath)
        self.movie = Movie(title: title, description: overview, imageUrl: url)
        
        if url != nil {
            Alamofire.request(url!).responseData(completionHandler: {
                response in
                self.movieImageView.image = UIImage(data: response.data!)
            })
        }
        
        setupDescriptionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDescriptionView() {
        let width = view.frame.width - (view.frame.width * 0.2)
        let descriptionView = UIView(frame: .zero)
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.backgroundColor = UIColor.darkGray
        descriptionView.alpha = 0.8
        descriptionView.layer.masksToBounds = true
        view.addSubview(descriptionView)
        
        let overviewLabel = UILabel(frame: .zero)
        let font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightLight)
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.numberOfLines = 0
        overviewLabel.preferredMaxLayoutWidth = width
        overviewLabel.font = font
        overviewLabel.textColor = UIColor.white
        descriptionView.addSubview(overviewLabel)
        overviewLabel.text = movie?.description
        let rect = rectForText(text: (movie?.description)!, font: font, maxSize: CGSize(width: width, height: 1000))
        
        let titleLabel = UILabel(frame: .zero)
        let titleFont = UIFont.systemFont(ofSize: 22.0, weight: UIFontWeightBold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = titleFont
        titleLabel.textColor = UIColor.white
        descriptionView.addSubview(titleLabel)
        titleLabel.text = movie?.title
        let titleRect = rectForText(text: (movie?.title)!, font: titleFont, maxSize: CGSize(width: width, height: 1000))
        
        let totalRect = CGSize(width: rect.width + titleRect.width + 20, height: rect .height + titleRect.height + 20)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        let viewsDictionary: [String: UIView] = ["descriptionView": descriptionView,
                               "overviewLabel": overviewLabel,
                               "titleLabel": titleLabel,
                               "view": view,
                               "scrollView": scrollView,
                               "uitabbar": (self.tabBarController?.tabBar)!]
        var allConstraints = [NSLayoutConstraint]()
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[titleLabel]-[overviewLabel]-8-|", options: [], metrics: nil, views: viewsDictionary)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[titleLabel]-8-|", options: [], metrics: nil, views: viewsDictionary)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[overviewLabel]-8-|", options: [], metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width).isActive = true
        NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: totalRect.height).isActive = true
        NSLayoutConstraint(item: scrollView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -44).isActive = true
        
        scrollView.addSubview(descriptionView)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[descriptionView]|", options: [], metrics: nil, views: viewsDictionary)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[descriptionView]|", options: [], metrics: nil, views: viewsDictionary)

        scrollView.contentSize = CGSize(width: totalRect.width, height: totalRect.height - 50.0)
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    func rectForText(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let rect = attrString.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        
        return size
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
