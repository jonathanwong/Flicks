//
//  NowPlayingTableViewCell.swift
//  Flicks
//
//  Created by Jonathan Wong on 3/29/17.
//  Copyright © 2017 Jonathan Wong. All rights reserved.
//

import UIKit
import Alamofire

class NowPlayingTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var movie: Movie? {
        didSet {
            movieTitleLabel.text = movie?.title
            movieDescriptionLabel.text = movie?.description
//            movieImageView.image = movie?.image
        }
    }
}
