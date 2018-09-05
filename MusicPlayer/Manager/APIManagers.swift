//
//  APIManagers.swift
//  MusicPlayer
//
//  Created by Naomi Schettini on 9/3/18.
//  Copyright © 2018 Naomi Schettini. All rights reserved.
//

import Foundation

class APIManagers  {
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    func getiTunesAPIResults(for enteredString: String?, completion: ((Result<SearchResult>) -> Void)?) {
        // The following code prepared the URL session and API call. It replaces the entered name's spaces with "+" signs for proper query format. The URL is then constructed and a request is made.
        var url = ""
        if let tmpEnteredString = enteredString {
            let queryString = tmpEnteredString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            url = "https://itunes.apple.com/search?term=\(queryString)"
        }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    /* Now we have jsonData, Data representation of the JSON returned to us
                     Create an instance of JSONDecoder to decode the JSON data to our
                     Codable struct */
                    let decoder = JSONDecoder()
        
                    do {
                        /* We would use SearchResult.self for JSON representing a single SearchResult object */
                        let searchResults = try decoder.decode(SearchResult.self, from: jsonData)
                        completion?(.success(searchResults))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    /* This prints the error in case there was an API call failure */
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func getLyricsAPIResults(for song: String, by artist: String, completion: ((Result<LyricsObject>) -> Void)?) {
        // The following code prepared the URL session and API call. It replaces the entered name's spaces with "+" signs for proper query format. The URL is then constructed and a request is made.
        let queryArtistString = artist.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let querySongString = song.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url = "https://lyrics.wikia.com/api.php?func=getSong&artist=\(queryArtistString)&song=\(querySongString)&fmt=realjson"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    let decoder = JSONDecoder()
                    
                    do {
                        /* We would use LyricsObject.self for JSON representing a single SearchResult object */
                        let lyricsObject = try decoder.decode(LyricsObject.self, from: jsonData)
                        completion?(.success(lyricsObject))
                    }
                    catch {
                        completion?(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion!(.failure(error))
                }
            }
        }
        task.resume()
    }
}
