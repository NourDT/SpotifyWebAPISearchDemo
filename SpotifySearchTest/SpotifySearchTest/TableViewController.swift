//
//  TableViewController.swift
//  SpotifySearchTest
//
//  Created by patrick on 3/25/17.
//  Copyright © 2017 Patrick Blaine. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    @IBOutlet weak var segments: UISegmentedControl!
    
    
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    
    private var selectedArtist:[String:Any] = [:]
    private var selectedTrack:[String:Any] = [:]
    private var selectedAlbum:[String:Any] = [:]
    private var selectedPlaylist:[String:Any] = [:]
    
    // MARK: - Search Controller
    var filteredTableTracksData:[Any] = []
    var filteredTableArtistsData:[Any] = []
    var filteredTableAlbumsData:[Any] = []
    var filteredTablePlaylistsData:[Any] = []
    var tableData:[Any] = []
    
    var searchController:UISearchController!
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredTableArtistsData.removeAll()
        filteredTableTracksData.removeAll()
        filteredTableAlbumsData.removeAll()
        filteredTablePlaylistsData.removeAll()
        
        guard let searchText = searchController.searchBar.text  else { return }
        
        let formattedSearch = searchText.replacingOccurrences(of: " ", with: "+")
        
        switch segments.selectedSegmentIndex {
        case 3:
            let searchURL = URL(string:"https://api.spotify.com/v1/search?q=\(formattedSearch)&type=playlist")
            let task = URLSession.shared.dataTask(with: searchURL!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {print("cannot parse JSON"); return}
                    
                    guard let wrapper = json["playlists"] as? [String:Any] else { print("cannot access tracks"); return }
                    
                    guard let playlists = wrapper["items"] as? [Any] else { print("cannot make array from all items"); return }
                    
                    self.filteredTablePlaylistsData = playlists
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print(error)
                }
            }
            task.resume()
            break
        case 2:
            
            let searchURL = URL(string:"https://api.spotify.com/v1/search?q=\(formattedSearch)&type=album")
            let task = URLSession.shared.dataTask(with: searchURL!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {print("cannot parse JSON"); return}
                
                guard let wrapper = json["albums"] as? [String:Any] else { print("cannot access tracks"); return }
                
                guard let albums = wrapper["items"] as? [Any] else { print("cannot make array from all items"); return }
                
                    self.filteredTableAlbumsData = albums
                    DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    }
                } catch let error {
                    print(error)
                }
            }
            task.resume()
            break
        case 1:
            
            
            let searchURL = URL(string:"https://api.spotify.com/v1/search?q=\(formattedSearch)&type=artist")
            
            let task = URLSession.shared.dataTask(with: searchURL!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                
                guard let wrapper = json["artists"] as? [String:Any] else { print("cannot access tracks"); return }
                
                guard let artists = wrapper["items"] as? [Any] else { print("cannot make array from all items"); return }
                
                self.filteredTableArtistsData = artists
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
            task.resume()
                break
        case 0:
            
            
            let searchURL = URL(string:"https://api.spotify.com/v1/search?q=\(formattedSearch)&type=track")
            
            let task = URLSession.shared.dataTask(with: searchURL!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                
                
                guard let wrapper = json["tracks"] as? [String:Any] else { print("cannot access tracks"); return }
                
                guard let tracks = wrapper["items"] as? [Any] else { print("cannot make array from all items"); return }
                self.filteredTableTracksData = tracks
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
                
                
            }
            
            task.resume()
            break
        default:
            print("other segment selected, do nothing")
        }
        
        
    }
    
    // MARK: - Targets
    
    func valueChanged() {
        updateSearchResults(for: searchController!)
        tableView.reloadData()
    }
    
    // MARK - ViewDid...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.ed
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchBar.sizeToFit()
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        // Reload the table
        self.tableView.reloadData()
        
        segments.addTarget(self, action: #selector(self.valueChanged), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchController.searchBar.text = ""
        self.searchController.searchBar.isHidden = false
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.searchController.isActive {return 1}
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.searchController.isActive {
            switch segments.selectedSegmentIndex {
            case 0:
                return self.filteredTableTracksData.count
            case 1:
                return self.filteredTableArtistsData.count
            case 2:
                return self.filteredTableAlbumsData.count
            case 3:
                return self.filteredTablePlaylistsData.count
            default:
                return 0
            }
        }
        return self.tableData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! TableViewCell
        
        // Configure the cell...
        
        if self.searchController.isActive {
            switch segments.selectedSegmentIndex {
            case 0:
                // Tracks
                guard let track = filteredTableTracksData[indexPath.row] as? [String:Any] else { return cell}
                cell.titleLabel.text = track["name"] as? String
                guard let artists = track["artists"] as? NSArray else {return cell}
                
                guard let artist = artists[0] as? NSDictionary else {return cell}
            cell.artistLabel.text = artist["name"] as? String
                guard let album = track["album"] as? NSDictionary else { return cell }
                cell.albumLabel.text = album["name"] as? String
                
            break
            case 1:
                // Artists
                
                guard let artist = filteredTableArtistsData[indexPath.row] as? [String:Any] else {return cell}
                cell.artistLabel.text = artist["name"] as? String
                cell.albumLabel.text = ""
                cell.titleLabel.text = ""
                break
            case 2:
                //albums
                
                guard let album = filteredTableAlbumsData[indexPath.row] as? [String:Any] else {return cell}
                
                cell.albumLabel.text = album["name"] as? String
                
                guard let artists = album["artists"] as? [Any] else { return cell}
                
                guard let artist = artists[0] as? [String:Any] else { return cell}
                
                cell.artistLabel.text = artist["name"] as? String
                
                cell.titleLabel.text = ""
                break
            case 3:
                guard let playlist = filteredTablePlaylistsData[indexPath.row] as? [String:Any] else {return cell}
            
                cell.titleLabel.text = playlist["name"] as? String
                
                guard let owner = playlist["owner"] as? [String:Any] else { return cell}
                cell.artistLabel.text = owner["id"] as? String
                guard let tracks = playlist["tracks"] as? [String:Any] else {return cell }
                guard let total = tracks["total"] as? Int else {return cell}
                cell.albumLabel.text = "\(total) tracks"
                break
            default:
                print("other segment selected, do nothing")
            }
        } else {
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.searchController.isActive {
            switch segments.selectedSegmentIndex {
            // Title
            case 0:
                guard let track = filteredTableTracksData[indexPath.row] as? [String:Any] else {return}
                selectedTrack = track
                performSegue(withIdentifier: "showTrack", sender: self)
                break
            case 1:
                guard let artist = filteredTableArtistsData[indexPath.row] as? [String:Any] else {return}
                selectedArtist = artist
                performSegue(withIdentifier: "showArtist", sender: self)
                break
            default:
                print("other segment selected, do nothing")
            }
        }
    }
    func stopPlayer() {
        guard let p = player else {return }
        do {
            try p.stop()
            guard var rItems = navigationItem.rightBarButtonItems else { return }
            rItems.removeAll()
            navigationItem.setRightBarButtonItems(rItems, animated: true)
        } catch {
            print("couldn't stop player")
        }
    }
    
    func skipTrack() {
        guard let p = player else { return }
        guard let ps = p.playbackState else { return }
        guard ps.isPlaying else {
            guard var rItems = self.navigationItem.rightBarButtonItems else { return }
            p.skipNext({ (error:Error?) in
                guard let e = error else {
                    return
                }
                if p.metadata.currentTrack! == p.metadata.prevTrack! {
                    
                    print(e)
                    
                    rItems.removeLast()
                    self.navigationItem.setRightBarButtonItems(rItems, animated: true)
                }
            })
            return
        }
    }
    
    func pausePlayer() {
        guard let p = player else { return }
        guard let ps = p.playbackState else { return }
        guard ps.isPlaying else { p.setIsPlaying(true, callback: { (error:Error?) in
            guard error == nil else { print(error!); return }
            
            self.navigationItem.setRightBarButtonItems([UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(self.pausePlayer))], animated: true)
            print("playing")
        }); return }
        p.setIsPlaying(false) { (error:Error?) in
            guard error == nil else { print(error!); return }
            
            self.navigationItem.setRightBarButtonItems([UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.pausePlayer))], animated: true)
            print("pausing")
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showArtist" {
            guard let dest = segue.destination as? ArtistViewController else { return }
            dest.artist = self.selectedArtist
            self.searchController.searchBar.isHidden = true
        } else if segue.identifier == "showTrack" {
            guard let dest = segue.destination as? TrackViewController else { return }
            dest.track = self.selectedTrack
            self.searchController.searchBar.isHidden = true
        } else {
            print("attempting unknown segue")
        }
    }
    
    // MARK: - Section Titles
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return -1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
}
