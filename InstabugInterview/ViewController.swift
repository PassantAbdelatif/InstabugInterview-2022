//
//  ViewController.swift
//  InstabugInterview
//
//  Created by Yousef Hamza on 1/13/21.
//

import UIKit
import InstabugNetworkClient

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NetworkClient.shared.get(URL(string: "https://test-customerapp.beuti.me/api/v1/Customer/getUserData")!) { data in
            print("get method called")
        }
        
        if let requests = NetworkClient.shared.allNetworkRequests(),
           requests.count > 0 {
            DispatchQueue.main.async {
            requests.forEach { request in
                print(request.url)
                print(request.method)
                print(request.statusCode)
                print(request.payload)
                print(request.response)
                print(request.errorCode)
                print(request.errorDomain)
            }
            }
        }
    }


}

