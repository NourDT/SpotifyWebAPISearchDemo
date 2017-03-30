//
//  AlbumViewController.swift
//  SpotifySearchTest
//
//  Created by patrick on 3/29/17.
//  Copyright © 2017 Patrick Blaine. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController, UITableViewDataSource {
    var album:[String:Any] = [:]
    var tracks:[Any] = []
    
    @IBOutlet weak var artistNameLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        albumNameLabel.text = album["name"] as? String
        guard let artists = album["artists"] as? [Any] else {return}
        guard let artist = artists[0] as? [String:Any] else {return}
        artistNameLabel.text = artist["name"] as? String
       
        guard let href = album["href"] as? String else { return }
        
        guard let url = URL(string: href) else { return}
        
        URLSession.shared.dataTask(with:url) { (data, response, error) in
            guard error == nil else { print(error!); return }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            do {
                guard let top = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return }
                guard let tracks = top["tracks"] as? [String:Any] else {return}
                guard let songs = tracks["items"] as? [Any] else { return }
                
                self.tracks = songs
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
            
            }.resume()
        
        guard let images = album["images"] as? [Any] else {print("couldn't access images"); return}
        
        guard let image = images[1] as? [String:Any] else {print("couldn't access medium image"); return}
        
        guard let imageURLString = image["url"] as? String else {print("bad url string"); return }
        
        
        guard let imageURL = URL(string: imageURLString) else {print("bad image url");return}
        
        let imageTask = URLSession.shared.dataTask(with: imageURL) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {print(error!);return}
            guard let data = data else { print("data is empty"); return}
            self.imageView.image = UIImage.init(data: data)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        imageTask.resume()    }

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
        
        guard let track = tracks[indexPath.row] as? [String:Any] else { return cell }
        cell.textLabel?.text = track["name"] as? String
        
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
