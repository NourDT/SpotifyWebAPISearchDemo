//
//  ViewController.swift
//  SpotifySearchTest
//
//  Created by patrick on 3/25/17.
//  Copyright © 2017 Patrick Blaine. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    func setup() {
        SPTAuth.defaultInstance().clientID = "e9e288ababc24ca4950bb5a40b1041a5"
        SPTAuth.defaultInstance().redirectURL = URL(string: "SpotifySearchTest://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthUserReadTopScope, SPTAuthUserReadEmailScope, SPTAuthUserReadPrivateScope, SPTAuthUserLibraryReadScope, SPTAuthUserLibraryModifyScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistReadCollaborativeScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessful"), object: nil)
        updateAfterFirstLogin()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let dest = segue.destination as! TableViewController
        dest.player = player
        dest.session = session
        
        
     }
 
    
    @IBAction func loginWithSpotifyPressed(_ sender: UIButton) {
        if UIApplication.shared.openURL(loginUrl!) {
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }
    }
    func updateAfterFirstLogin () {
        if let sessionObj:AnyObject = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            initializePlayer(authSession: session)
        } else {
            print("no token stored")
        }
    }
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
            player?.setRepeat(.off, callback: { (error:Error?) in
                guard let e = error else {
                    return
                }
                
                print(e)
                
            })
            player?.setShuffle(false, callback: { (error:Error?) in
                guard let e = error else { return }
                
                print(e)
            })
        } else {
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        performSegue(withIdentifier: "showSearch", sender: self)
    }
    
    @IBAction func logoutUnwind(segue:UIStoryboardSegue) {
        player?.logout()
        UserDefaults.standard.removeObject(forKey: "SpotifySession")
        UserDefaults.standard.synchronize()
        
    }
}
