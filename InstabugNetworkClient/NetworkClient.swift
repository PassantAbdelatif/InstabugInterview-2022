//
//  NetworkClient.swift
//  InstabugNetworkClient
//
//  Created by Yousef Hamza on 1/13/21.
//

import Foundation

public class NetworkClient {
    public static var shared = NetworkClient()
    
    // MARK: Network requests
    public func get(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "GET", payload: nil, completionHandler: completionHandler)
    }
    
    public func post(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "POSt", payload: payload, completionHandler: completionHandler)
    }
    
    public func put(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "PUT", payload: payload, completionHandler: completionHandler)
    }
    
    public func delete(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "DELETE", payload: nil, completionHandler: completionHandler)
    }
    
    func executeRequest(_ url: URL,
                        method: String,
                        payload: Data?,
                        completionHandler: @escaping (Data?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = payload
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
#warning("Record request/response")
            //  fatalError("Not implemented")
            
           
                
                var statusCode: Int16?
                if let httpResponse = response as? HTTPURLResponse {
                    statusCode = Int16(httpResponse.statusCode)
                }
                var errorDomain: String?
                var errorCode: Int16?
                if let error = error as? NSError {
                    errorCode = Int16(error.code)
                    errorDomain = error.domain
                }
            
         //   DispatchQueue.global(qos: .background).async {
                self.createRequestModel(requestUrl: url,
                                        method: method,
                                        payload: payload ?? Data(),
                                        response: data ?? Data(),
                                        errorDomain: errorDomain,
                                        errorCode: errorCode,
                                        statusCode: statusCode ?? 0)
                DispatchQueue.main.async {
                    completionHandler(data)
                }
           // }
            

        }.resume()
    }
    
    func createRequestModel(requestUrl: URL,
                            method: String,
                            payload: Data?,
                            response: Data?,
                            errorDomain: String?,
                            errorCode: Int16?,
                            statusCode: Int16){
        
        let context = InstabugNetworkDataManager.shared.backgroundContext
        context.perform {
            
            let requestModel = RequestModel(context: context)
            //The framework should store up to 1,000 records
            if let requests =  InstabugNetworkDataManager.shared.fetch(entity: RequestModel.self),
               requests.count.isMoreThan1000Record {
                InstabugNetworkDataManager.shared.deleteFirstRecord(entity: RequestModel.self)
            }
            
            requestModel.url = requestUrl
            requestModel.method  = method
            //The payload body for request and response should not be larger than 1 MB
            if let requestPayload = payload {
                if requestPayload.count.isLessThan1MB {
                    requestModel.payload = payload
                } else {
                    requestModel.payload = Data("payload too large".utf8)
                }
            }
            if let responsePayload = response {
                if responsePayload.count.isLessThan1MB {
                    requestModel.response = response
                } else {
                    requestModel.response = Data("payload too large".utf8)
                }
            }
            requestModel.errorDomain = errorDomain
            requestModel.errorCode = errorCode ?? 0
            requestModel.statusCode = statusCode
            InstabugNetworkDataManager.shared.insert(object: requestModel)
        }
    }
    
    // MARK: Network recording
#warning("Replace Any with an appropriate type")
    public func allNetworkRequests() -> [RequestModel]? {
        //fatalError("Not implemented")
        if let allRequests = InstabugNetworkDataManager.shared.fetch(entity: RequestModel.self) {
            return allRequests
        }
        return nil
    }
}
