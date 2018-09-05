//
//  SearchMusicViewController.swift
//  MusicPlayer
//
//  Created by Naomi Schettini on 9/3/18.
//  Copyright © 2018 Naomi Schettini. All rights reserved.
//

import UIKit

class SearchMusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate {
    
    //MARK:-
    //MARK:- Properties
    /// Class Variables
    /* The api manager contains the functions for both API calls needed for this app */
    let apiManager = APIManagers()
    /* totalMusicResultsArray is an array that holds the total amount of Music Objects loaded after pagination */
    var totalMusicResultsArray = [MusicObject]()
    /* paginatedMusicResultsArray is an array that holds the amount of Music Objects loaded during pagination */
    var paginatedMusicResultsArray = [MusicObject]()
    /* currentCapacity is a variable of type Int that is incremented each time a pagination occurs */
    var currentCapacity = 20
    /* selectedMusicObject is a variable of type MusicObject that is set when the user selects a table view cell containing a music object */
    var selectedMusicObject: MusicObject? = nil
    /* searchController is a variable of type UISearchController that has a searchBar component and can easily be implanted into the Navigation Controller */
    var searchController: UISearchController! = UISearchController(searchResultsController: nil)
    
    /* selectedLyricsObject is a variable of type Lyrics object that is set when the lyrics wikia API is called and finds lyrics that match up to the passed in Music Object  */
    private var selectedLyricsObject: LyricsObject? = nil
    
    
    /// IBOutlets
    /* The resultTableView is a UITableView that is for displaying the found Music Objects */
    @IBOutlet weak var resultTableView: UITableView!
    /* The noResultsView is a UIView that reads "No results", default state is hidden */
    @IBOutlet weak var noResultsView: UIView!
    
    
    //MARK:-
    //MARK:- View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The UI for the navigationbar and SearchController is done in the viewDidLoad.
        self.title = "Search Music"
        
        // set the delegate and data source for resultTableView
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        // for the sake of simplicity, UISearchController was used in this exercise. However, in real life an alternative Apple component would be implemented for users who have no updated their phones to iOS 11.
        if #available(iOS 11.0, *) {
            
            searchController.delegate = self
            
            let searchBar = searchController.searchBar
            searchBar.tintColor = UIColor.white
            searchBar.barTintColor = UIColor.white
            searchBar.delegate = self
            
            if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.darkGray
                textfield.placeholder = "Enter the name of a song..."
                if let backgroundview = textfield.subviews.first {
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                }
            }
            
            if let navigationbar = self.navigationController?.navigationBar {
                navigationbar.barTintColor = UIColor.init(red: 97.0/255.0, green: 132.0/255.0, blue: 216.0/255.0, alpha: 1.0)
            }
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            self.showAlertWithMessage(message: "Update your software to iOS 11")

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /// When the user navigates back to the view controller after clicking back. Clear all data.
        paginatedMusicResultsArray.removeAll()
        totalMusicResultsArray.removeAll()
        resultTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // To avoid the problem with the AlertController not being presented when the SearchController is active
        searchController.dismiss(animated: false, completion: nil)
    }
    
    //MARK:-
    //MARK:- UISearchBarDelegate Methods
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // remove all objects in the array if the search is canceled.
        self.noResultsView.isHidden = true
        totalMusicResultsArray.removeAll()
        paginatedMusicResultsArray.removeAll()
    }
    // When the search controller is inactive, hide the no results view
    func didDismissSearchController(_ searchController: UISearchController) {
        self.noResultsView.isHidden = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // For the simple exercise, I assumed an entire name would be entered. However, in real life, you would also want to keep track of the string being entered into the search bar as the user is typing to live update the results. There are third party libraries which make that easier.
        if searchBar.text?.count == 0 {
            totalMusicResultsArray.removeAll()
            paginatedMusicResultsArray.removeAll()
        }
    }
    // When the search controller is active, hide the no results view
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.noResultsView.isHidden = true
    }
    
    /// When the user has entered "Tom Waits" or "Macy Gray", call the itunes API to retrieve all tracks featured by that artist. If the returned results have the value "song" for the "kind" key, it is indeed a song and will be displayed in the table view.
    /// Pagination
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        apiManager.getiTunesAPIResults(for: searchBar.text) { (result) in
            switch result {
            case .success(let searchResult):
                self.noResultsView.isHidden = true
                for result in searchResult.results! {
                    if result.kindOfMedia == "song" {
                        self.totalMusicResultsArray.append(result)
                    }
                }
                // If the resultCount property of the SearchResult is equal to 0, let the user know by an alert saying nothing has been found.
                if searchResult.results?.count == 0 {
                    self.noResultsView.isHidden = false
                }
                self.paginatedMusicResultsArray.reserveCapacity(self.currentCapacity)
                self.paginatedMusicResultsArray.append(contentsOf: self.totalMusicResultsArray)
                self.resultTableView.reloadData()
            case .failure(let error):
                self.showAlertWithMessage(message: "\(error.localizedDescription)")
            }
        }
    }
    
    
    //MARK:-
    //MARK:- UITableViewDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paginatedMusicResultsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    /// When a table view cell is selected, the lyrics API is called and if the returned response from the closure is true, the "showLyricsViewController" segue is performed. If the reponse is false, an alert is presented.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMusicObject = paginatedMusicResultsArray[indexPath.row]
        retrieveLyics { (isFound) in
            if isFound == true {
                self.performSegue(withIdentifier: "showLyricsViewController", sender: self)
            }
            else {
                self.showAlertWithMessage(message: "Could not locate lyrics for that song.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// Pagination logic.
        if indexPath.row == paginatedMusicResultsArray.count - 1 {
            // conditional checking there there are more items to fetch
            if totalMusicResultsArray.count > paginatedMusicResultsArray.count {
                let newArray = totalMusicResultsArray[currentCapacity-1...currentCapacity+19]
                paginatedMusicResultsArray.append(contentsOf: newArray)
            }
        }
        /// Set up the Cell's UI
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMusicResultTableViewCell") as? SearchMusicResultTableViewCell
        cell?.setUpTableViewCellUIWithMusicObject(paginatedMusicResultsArray[indexPath.row])
        return cell!
    }
    
    //MARK:-
    //MARK:- Helper Function
    /* This function calls the wikia lyrics API to verify if lyrics exist for the selected Music Object's track name and artist name. If lyrics are found, a Bool value of true is returned to permit the user to segue onto the LyricsViewController to view the lyrics.
    */
    func retrieveLyics(completion: @escaping (_ found: Bool) -> ()){
        if let selectedMusic = selectedMusicObject {
            apiManager.getLyricsAPIResults(for: selectedMusic.trackName!, by: selectedMusic.artistName!) { (result) in
                switch result {
                case .success(let song):
                    self.selectedLyricsObject = song
                    completion(true)
                case .failure(let error):
                    completion(false)
                    self.showAlertWithMessage(message: "\(error.localizedDescription)")
                }
            }
        }
    }
    
    /*
     This helper function allows for a message string to be passed into an Alert Controller and displays the Alert Controller to avoid having alerts presented from inside completion blocks */
    func showAlertWithMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:-
    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// Verify the destination is to the lyrics view controller and pass the selected song's lyrics
        if segue.identifier == "showLyricsViewController" {
            if let destinationVC = segue.destination as? LyricsViewController {
                if let tmpLyrics = self.selectedLyricsObject?.lyrics {
                destinationVC.lyricsString = tmpLyrics
                }
            }
        }
    }
}


//MARK:-
//MARK:-
//MARK:- SearchMusicResultTableViewCell Class
class SearchMusicResultTableViewCell: UITableViewCell {
    // IBOutlets
    /* The artistNameLabel is a variable of type UILabel that is for displaying the artist's name */
    @IBOutlet weak var artistNameLabel: UILabel!
    /* The trackNameLabel is a variable of type UILabel that is for displaying the song's title */
    @IBOutlet weak var trackNameLabel: UILabel!
    /* The albumNameLabel is a variable of type UILabel that is for displaying the album's name */
    @IBOutlet weak var albumNameLabel: UILabel!
    /* The artistArtworkImageView is a variable of type UIImageView that is for displaying the album artwork image */
    @IBOutlet weak var artistArtworkImageView: UIImageView!
    
    // Set up the Table View Cell's UI
    func setUpTableViewCellUIWithMusicObject(_ musicObject: MusicObject) {
        if let tmpArtistName = musicObject.artistName {
            artistNameLabel.text = tmpArtistName
        }
        if let tmpTrackName = musicObject.trackName {
            trackNameLabel.text = tmpTrackName
        }
        if let tmpAlbumName = musicObject.albumName {
            albumNameLabel.text  = tmpAlbumName
        }
        if musicObject.imageURL != nil {
            // Set the avatar image with the image URL String passed from the music Object
            let url = URL(string: musicObject.imageURL!)
            let data = try? Data(contentsOf: url!)
            artistArtworkImageView.image = UIImage(data: data!)
        }
    }
}
