//
//  PlaylistViewController.swift
//  SpotifySearchTest
//
//  Created by patrick on 3/29/17.
//  Copyright © 2017 Patrick Blaine. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var playlistOwnerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var playlist:[String:Any] = [:]
    
    var tracks:[Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        playlistNameLabel.text = playlist["name"] as? String
        guard let owner = playlist["owner"] as? [String:Any] else {return}
        playlistOwnerLabel.text = owner["id"] as? String
        guard let t = playlist["tracks"] as? [String:Any] else {return}
        
        guard let href = t["href"] as? String else { return }
        
        guard let url = URL(string: href) else { return}
        var urlRequest = URLRequest.init(url: url)
        if let sessionObj:AnyObject = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            print("\(firstTimeSession.accessToken!)")
            urlRequest.addValue("Bearer \(firstTimeSession.accessToken!)",
            forHTTPHeaderField: "Authorization")
        } else {
            print("no token stored")
        }
        
        URLSession.shared.dataTask(with:urlRequest) { (data, response, error) in
            guard error == nil else { print(error!); return }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            do {
                guard let top = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return }
                print(top)
                guard let songs = top["items"] as? [Any] else { return }
                
                self.tracks = songs
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }

        }.resume()
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
            return tracks.count
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") else { return UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        guard let t = tracks[indexPath.row] as? [String:Any] else { return cell }
        guard let track = t["track"] as? [String:Any] else { return cell}
            cell.textLabel?.text = track["name"] as? String
        guard let artists = track["artists"] as? [Any] else { return cell }
        guard let artist = artists[0] as? [String:Any] else { return cell }
        
        cell.detailTextLabel?.text = artist["name"] as? String
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Tracks"
        default:
            return nil
        }
    }
}
