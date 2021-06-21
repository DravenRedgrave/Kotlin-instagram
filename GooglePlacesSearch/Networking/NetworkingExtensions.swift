//
//  NetworkingExtensions.swift
//  GooglePlacesSearch
//
//  Created by Michael Miles on 3/17/19.
//  Copyright © 2019 Michael Miles. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension ResultViewController {
    func accessDetail(placeID: String) {
        let googleURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&fields=name,formatted_address,formatted_phone_number,rating,user_ratings_total,website&key=AIzaSyANAB2qpcDlxNOy74FD_n1UfaTOl6SD0QA"
        
        Alamofire.request(googleURL, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let result = JSON(response.result.value!)
                self.updatePlaceDetail(json: result)
                print(result)
            } else {
                let errorMessage = String(describing: response.result.error)
                print("Error \(errorMessage)")
                let alertController = UIAlertController(title: "Network Error", message: "Error connecting to network \(errorMessage)", preferredStyle: .alert)
                
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                
                alertController.addAction(actionOk)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
