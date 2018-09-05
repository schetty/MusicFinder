//
//  MusicObject.swift
//  MusicPlayer
//
//  Created by Naomi Schettini on 9/3/18.
//  Copyright © 2018 Naomi Schettini. All rights reserved.
//

import Foundation

/* Using Swift 4's Decodable protocol, 2 structs are made for parsing the JSON from the itunes API. The JSON is returned in as an array of dicionaries of two keys: resultCount (non optional) and results (optional). Results may return a value of 0, results may be completely empty. The SearchResult struct is for parsing the outermost shell of the received JSON. */
struct SearchResult: Decodable {
    var resultCount: Int
    var results: [MusicObject]?
}

/* The MusicObject struct is for parsing the needed values from the nested container in the "results" dictionary. The needed values include: artist name, track name, album name, the image URL for the album artsork, and the type of media the object is. */

struct MusicObject: Decodable {
    var artistName: String?
    var trackName: String?
    var albumName: String?
    var imageURL: String?
    var kindOfMedia: String?
    
    enum ResultsKeys: String, CodingKey {
        case kind
        case artistName
        case trackName
        case collectionName
        case artworkUrl100
    }
    
    //* The decoding and initializing of the Music Object occurs in this method. */
    init(from decoder: Decoder) throws {
        let results = try decoder.container(keyedBy: ResultsKeys.self)
        kindOfMedia = try results.decodeIfPresent(String.self, forKey: .kind)
        artistName = try results.decodeIfPresent(String.self, forKey: .artistName)
        trackName = try results.decodeIfPresent(String.self, forKey: .trackName)
        albumName = try results.decodeIfPresent(String.self, forKey: .collectionName)
        imageURL = try results.decodeIfPresent(String.self, forKey: .artworkUrl100)
    }
    
    func encode(to encoder: Encoder) {
    }
}
