# SpotifySearchTest
## A demonstration of interacting with Spotify's new Web API to perform searches in Swift 3.
### There's a Web API Console on Spotify's Developer page that allows you to test your Web API requests: https://developer.spotify.com/web-api/console/get-search-item/.
#### The steps for performing a search are:
            
    let searchText = "Something"
        
    let formattedSearch = searchText.replacingOccurrences(of: " ", with: "+")

    let searchURL = URL(string:"https://api.spotify.com/v1/search?q=\(formattedSearch)&type=track")
            
    URLSession.shared.dataTask(with: searchURL!) { data, response, error in
      guard error == nil else {
        print(error!)
        return
      }
      guard let data = data else {
      print("Data is empty")
      return
      }
      
      do {
          guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { print("cannot parse json")
          guard let wrapper = json["tracks"] as? [String:Any] else { print("cannot access tracks"); return }
                
          guard let tracks = wrapper["items"] as? [Any] else { print("cannot make array from all items"); return }
                
          print(tracks) // this array is full of all the results of your search
      } catch let error {
          print(error)
      }
                
    }.resume()
