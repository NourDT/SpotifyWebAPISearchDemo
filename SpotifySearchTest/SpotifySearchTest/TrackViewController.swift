//
//  TrackViewController.swift
//  SpotifySearchTest
//
//  Created by patrick on 3/29/17.
//  Copyright © 2017 Patrick Blaine. All rights reserved.
//

import UIKit

class TrackViewController: UIViewController {

    var track:[String:Any] = [:]
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleLabel.text = track["name"] as? String
        
        guard let artists = track["artists"] as? [Any] else {print("couldn't access artists"); return}
        
        guard let artist = artists.first as? [String:Any] else {print("couldn't access artists.first()"); return}
        
        artistLabel.text = artist["name"] as? String
        
        guard let album = track["album"] as? [String:Any]
        else {print("couldn't access album"); return}
        
        albumLabel.text = album["name"] as? String
        
        guard let images = album["images"] as? [Any] else {print("couldn't access images"); return}
        
        guard let image = images[1] as? [String:Any] else {print("couldn't access medium image"); return}
        
        guard let imageURLString = image["url"] as? String else {print("bad url string"); return }
        
        
        guard let imageURL = URL(string: imageURLString) else {print("bad image url");return}
        
        let imageTask = URLSession.shared.dataTask(with: imageURL) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {print(error!);return}
            guard let data = data else { print("data is empty"); return}
            self.imageView.image = UIImage.init(data: data)
        }
        
        imageTask.resume()
        
        
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

}
