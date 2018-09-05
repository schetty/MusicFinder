//
//  LyricsObject.swift
//  MusicPlayer
//
//  Created by Naomi Schettini on 9/4/18.
//  Copyright © 2018 Naomi Schettini. All rights reserved.
//

import Foundation

//* Using Swift 4's Decodable protocol, 2 structs are made for parsing the JSON from the lyrics wikia API. The JSON is returned in as a dicionary of some keys. The Lyrics struct is for parsing the artist's name, song, and lyrics strings. They are all optionals because the API may return no information at all. The only needed data is lyrics, however, I decided to also store the artist and song information in case there is future need of extra validation for edge cases. */

struct LyricsObject: Decodable {
    var artist: String?
    var song: String?
    var lyrics: String?
    
    
    enum ResultsKeys: String, CodingKey {
        case artist
        case song
        case lyrics
    }
    
    init(from decoder: Decoder) throws {
        let results = try decoder.container(keyedBy: ResultsKeys.self)
        artist = try results.decodeIfPresent(String.self, forKey: .artist)
        song = try results.decodeIfPresent(String.self, forKey: .song)
        lyrics = try results.decodeIfPresent(String.self, forKey: .lyrics)
        
    }
}

