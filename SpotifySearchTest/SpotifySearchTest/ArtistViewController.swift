//
//  ArtistViewController.swift
//  SpotifySearchTest
//
//  Created by patrick on 3/28/17.
//  Copyright © 2017 Patrick Blaine. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var artist:[String:Any] = [:]
    
    var topSongs:[Any] = []
    var albums:[Any] = []
    var relatedArtists:[Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        artistLabel.text = artist["name"] as? String
        print(artist)
        print(artist["id"] as! String)
        guard let topSongsURL = URL(string: "https://api.spotify.com/v1/artists/\(artist["id"] as! String)/top-tracks?country=US") else { print("bad url"); return }
        
        let topSongsTask = URLSession.shared.dataTask(with: topSongsURL) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else { print("\(error!)");return }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            do {
                guard let top = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return }
                guard let songs = top["tracks"] as? [Any] else { return }
                
                self.topSongs = songs
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
            
            
        }
        
        topSongsTask.resume()
        
        guard let images = artist["images"] as? NSArray else { print("couldn't do images");return }
        guard let img = images[1] as? NSDictionary else {print("couldn't do img"); return }
        guard let imageURLString = img["url"] as? String else {print("bad image url string"); return}
        guard let imageURL = URL(string: imageURLString) else {print("bad image url"); return}
        
        let imageTask = URLSession.shared.dataTask(with: imageURL) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {print(error!);return}
            guard let data = data else { print("data is empty"); return}
            self.imageView.image = UIImage.init(data: data)
        }
        
        imageTask.resume()
        
        guard let albumsURL = URL(string: "https://api.spotify.com/v1/artists/\(artist["id"] as! String)/albums") else { print("bad albums url"); return }
        
        URLSession.shared.dataTask(with: albumsURL, completionHandler: { (data, response, error) in
            guard error == nil else { print(error!); return}
            guard let data = data else { print("data is empty"); return }
        
        
            guard let top = try! JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { print("couldn't parse json"); return }
            
            guard let albumResults = top["items"] as? [Any] else { self.albums = [ top ]; return }
            
            self.albums = albumResults
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
            
        }).resume()
        
        guard let relatedArtistsURL = URL(string: "https://api.spotify.com/v1/artists/\(artist["id"] as! String)/related-artists") else { print("bad related artists url"); return }
        
        URLSession.shared.dataTask(with: relatedArtistsURL, completionHandler: { (data, response, error) in
            guard error == nil else { print(error!); return}
            guard let data = data else { print("data is empty"); return }
            
            
            guard let top = try! JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { print("couldn't parse json"); return }
            
            guard let relatedArtistsResults = top["artists"] as? [Any] else { print("couldn't access artists"); return }
            print(relatedArtistsResults)
            self.relatedArtists = relatedArtistsResults
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
            
        }).resume()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return topSongs.count
        case 1:
            return albums.count
        case 2:
            return relatedArtists.count
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") else { return UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        if indexPath.row < topSongs.count && indexPath.section == 0 {
            // top songs
            guard let song = topSongs[indexPath.row] as? [String:Any] else { return cell}
            
            cell.textLabel?.text = song["name"] as? String
        }
        else if indexPath.row < albums.count && indexPath.section == 1 {
            // albums
            guard let album = albums[indexPath.row] as? [String:Any] else {return cell}
            
            cell.textLabel?.text = album["name"] as? String
        }
        else if indexPath.row < relatedArtists.count && indexPath.section == 2 {
            // albums
            guard let artist = relatedArtists[indexPath.row] as? [String:Any] else {return cell}
            
            cell.textLabel?.text = artist["name"] as? String
        }
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
    return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Top Tracks"
        case 1:
            return "Albums"
        case 2:
            return "Related Artists"
        default:
            return nil
        }
    }
    
}
