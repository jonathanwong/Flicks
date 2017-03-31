//
//  Movie.swift
//  Flicks
//
//  Created by Jonathan Wong on 3/29/17.
//  Copyright © 2017 Jonathan Wong. All rights reserved.
//

import UIKit

class Movie {
    var title: String
    var description: String
    var imageUrl: URL?
    
    init(title: String, description: String, imageUrl: URL?) {
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
    }
}
