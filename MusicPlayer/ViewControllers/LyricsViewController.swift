//
//  LyricsViewController.swift
//  MusicPlayer
//
//  Created by Naomi Schettini on 9/3/18.
//  Copyright © 2018 Naomi Schettini. All rights reserved.
//

import UIKit

class LyricsViewController: UIViewController {
    
    var lyricsString = ""
    @IBOutlet weak var lyricsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let spacedLyrics = lyricsString.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil)
        lyricsLabel.text = spacedLyrics

    }

    func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
