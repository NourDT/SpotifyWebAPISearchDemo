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
    
    private var selectedArtist = NSDictionary()
    
    // MARK: - Search Controller
    var filteredTableTracksData:[NSDictionary] = []
    var filteredTableArtistsData:[NSDictionary] = []
    var tableData:[String] = []
    
    var searchController:UISearchController!
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredTableArtistsData.removeAll()
        filteredTableTracksData.removeAll()
        
        guard let searchText = searchController.searchBar.text  else { return }
        
        let formattedSearch = searchText.replacingOccurrences(of: " ", with: "+")
        
        switch segments.selectedSegmentIndex {
        case 1:
            
            filteredTableArtistsData.removeAll()
            
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
                
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                
                guard let wrapper = json.value(forKey: "artists") as? NSDictionary else { print("cannot access tracks"); return }
                
                guard let artists = wrapper.value(forKey: "items") as? NSArray else { print("cannot make array from all items"); return }
                
                for artist in artists {
                    let a = artist as! NSDictionary
                    self.filteredTableArtistsData.append(a)
                }
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
            task.resume()
                break
        case 0:
            
            self.filteredTableTracksData.removeAll()
            
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
                
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                
                
                guard let wrapper = json.value(forKeyPath: "tracks") as? NSDictionary else { print("cannot access tracks"); return }
                
                guard let tracks = wrapper.value(forKey: "items") as? NSArray else { print("cannot make array from all items"); return }
                
                for track in tracks {
                    let t = track as! NSDictionary
                    guard let name = t["name"] as? String else {return}
                    guard let artists = t["artists"] as? NSArray else { return }
                    guard let artist = artists[0] as? NSDictionary else { return }
                    guard let artistName = artist["name"] as? String else {return}
                    guard let album = t["album"] as? NSDictionary else { return }
                    guard let albumName = album["name"] as? String else { return }
                    guard let uri = t["uri"] as? String else {return}
                    print("\(name) by \(artistName) off of the album \(albumName) | \(uri)")
                    self.filteredTableTracksData.append(t)
                }
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
                let track = filteredTableTracksData[indexPath.row]
                cell.titleLabel.text = track["name"] as? String
                guard let artists = track["artists"] as? NSArray else {return cell}
                
                guard let artist = artists[0] as? NSDictionary else {return cell}
            cell.artistLabel.text = artist["name"] as? String
                guard let album = track["album"] as? NSDictionary else { return cell }
                cell.albumLabel.text = album["name"] as? String
                
            break
            case 1:
                // Artists
                
                let artist = filteredTableArtistsData[indexPath.row]
                cell.artistLabel.text = artist.value(forKey: "name") as? String
                cell.albumLabel.text = ""
                cell.titleLabel.text = ""
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
                
                let track = filteredTableTracksData[indexPath.row] as NSDictionary
                
                guard let uri = track.object(forKey: "uri") as? String else { return}
                
                if let player = player {
                    if let ps = player.playbackState {
                        if !ps.isPlaying {
                            player.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0, callback: { (error:Error?) in
                                guard error == nil else { print(error!);return }
                                print("track started \(uri)")
                                
                            })
                        } else {
                            guard var rItems = self.navigationItem.rightBarButtonItems else { return }
                            if rItems.count < 2 {
                                rItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(self.skipTrack)))
                                self.navigationItem.setRightBarButtonItems(rItems, animated: true)
                            } else {
                                rItems[0] = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(self.skipTrack))
                                self.navigationItem.setRightBarButtonItems(rItems, animated: true)
                            }
                            player.queueSpotifyURI(uri, callback: { (error:Error?) in
                                guard error == nil else { print(error!); return }
                                
                            })
                        }
                    } else {
                        
                        
                        player.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0, callback: { (error:Error?) in
                            guard error == nil else { print(error!);return }
                            print("track started \(uri)")
                            
                        })
                        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(self.pausePlayer)),UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(self.skipTrack))]
                    }
                }
                break
            case 1:
                selectedArtist = filteredTableArtistsData[indexPath.row]
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
            
            guard let rItems = self.navigationItem.rightBarButtonItems, let l = rItems.last else { return }
            
            self.navigationItem.setRightBarButtonItems([UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(self.pausePlayer)), l], animated: true)
            print("playing")
        }); return }
        p.setIsPlaying(false) { (error:Error?) in
            guard error == nil else { print(error!); return }
            guard let rItems = self.navigationItem.rightBarButtonItems, let l = rItems.last else { return }
            
            self.navigationItem.setRightBarButtonItems([UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.pausePlayer)), l], animated: true)
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
