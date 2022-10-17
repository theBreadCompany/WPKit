//
//  WPPublicAPI.swift
//  
//
//  Created by Fabio Mauersberger on 18.08.22.
//
//  No async funcs are used to maintain compatibility to older versions of Swift 5

import Foundation
import Metal

/**
 Provide the methods that are relevant for everyone who simply wants to obtain the content of the website.
 
 This class is limited to provide content, not to edit or delete it.
 It requires no authorization and is accessible for everyone.
 This is done via the REST API that every WordPress website has.
 */
public class WPPublicAPI {
    
    /// For now, the host is hardcoded as it is
    public let host = URL(string: "https://www.volksverpetzer.de")!
    /// This property gets updated with every query.
    public var availablePosts = 0
    
    
    public init(fetchAvailableCount: Bool = false) {
        if fetchAvailableCount {
            let _ = try? self.fetchPosts()
        }
    }
    
    public func fetchPosts(limit: Int = 0, having fields: [WPPost.Property] = [], offset: Int = 0) throws -> [WPPost] {
        var params = ["offset": offset.description]
        if !fields.isEmpty {
            params.updateValue((fields + .id + .guid + .date_gmt + .modified_gmt).map({$0.rawValue}).joined(separator: ","), forKey: "_fields") }
        if fields.contains(._embedded) {
            params.updateValue("1", forKey: "_embed") }
        guard let req = URLRequest(host: host,
                                   path: "/wp-json/wp/v2/posts",
                                   using: .GET,
                                   with: params) else { throw WPError.badRequest }
        return try request(req, expected: [WPPost].self)
    }
    
    public func fetchPosts(limit: Int = 0, having fields: [WPPost.Property] = [], offset: Int = 0, completionHandler: @escaping ([WPPost]?, Error?) -> ()) {
        var params = ["offset": offset.description]
        if !fields.isEmpty {
            params.updateValue((fields + .id + .guid + .date_gmt + .modified_gmt).map({$0.rawValue}).joined(separator: ","), forKey: "_fields") }
        if fields.contains(._embedded) {
            params.updateValue("1", forKey: "_embed") }
        if let req = URLRequest(host: host,
                                path: "/wp-json/wp/v2/posts",
                                using: .GET,
                                with: params) {
            request(req, expected: [WPPost].self) { result, error in
                completionHandler(result, error)
            }
        } else {
            completionHandler(nil, WPError.badRequest)
        }
    }
    
    internal class func decode<T: Codable>(data: Data, expected type: T.Type) throws -> T {
        wplog("Trying to decode response data...")
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        let result = try! decoder.decode(T.self, from: data)
        wplog("Decoding succeeded, returning results...")
        return result
    }
    
    public func request<T: Codable>(_ request: URLRequest, expected type: T.Type, completionHandler: @escaping (T?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { _data, _response, _error in
            wplog("Data task completed, let's check if its contents are valid...")
            guard _error == nil, let response = _response as? HTTPURLResponse else {
                wplog("The request finished with an error or the response couldnt be processed!")
                return completionHandler(nil, _error ?? WPError.badResult)
            }
            if let data = _data, let decodedData = try? Self.decode(data: data, expected: type) {
                if let posts = response.allHeaderFields["X-WP-Total"] as? Int {
                    wplog("Also found a total post count ", posts)
                    self.availablePosts = posts
                }
                completionHandler(decodedData, nil)
            } else {
                print(response.statusCode)
                wplog("Something bad happened, check this HTTP code: ", response.statusCode)
                completionHandler(nil, Self.handle(statusCode: response.statusCode))
            }
        }
        task.resume()
    }
    
    /**
     My implementation of a URLRequest helper function to keep things nice and clean as it provides both sync and async functionality with little work.
     */
    public func request<T: Codable>(_ request: URLRequest, expected type: T.Type) throws -> T {
        
        let semaphore = DispatchSemaphore(value: 0) // yes, its time for that move...
        var responseData: Data?
        let task = URLSession.shared.dataTask(with: request) { data, response, _ in
            wplog("Data task completed, let's check if there is any content...")
            if let data = data {
                wplog("There is content...")
                responseData = data
                wplog("Checking for page count...")
                if let posts = Int((response as? HTTPURLResponse)?.allHeaderFields["x-wp-totalpages"] as? String ?? "") {
                    wplog("Got page count of ", posts)
                    self.availablePosts = posts
                }
            } else {
                wplog("No content to found...")
            }
            semaphore.signal()
        }
        task.resume()
        wplog("Data task started, blocking thread until completed...")
        semaphore.wait()
        
        guard task.error == nil, let response = task.response as? HTTPURLResponse else { throw WPError.badResult }
        if let responseData = responseData {
            return try Self.decode(data: responseData, expected: type)
        } else {
            wplog("Something bad happened, check this HTTP code: ", response.statusCode)
            throw Self.handle(statusCode: response.statusCode)
        }
    }
    
    internal class func handle(statusCode: Int) -> WPError {
        switch statusCode {
        case 400:
            return WPError.badRequest
        case 401:
            return WPError.authMissing
        case 403:
            return WPError.authFailed
        case 404:
            return WPError.endpointNotFound
        default:
            return WPError.badResult
        }
    }
}

public extension URLRequest {
    
    init?(host: URL, path: String, using method: HTTPMethod, with params: Dictionary<String,String> = [:], with data: Dictionary<String, String> = [:]) {
        var components = URLComponents()
        wplog("Trying to build request for ", host.absoluteString, path)
        components.scheme = host.scheme
        components.host = host.host
        components.path = path
        components.queryItems = params.map { (URLQueryItem(name: $0.key, value: $0.value)) }
        wplog("Total query components: ", components.queryItems?.description ?? "nil")
        guard let url = components.url else {
            wplog("URL could not be built from components!")
            return nil
        }
        wplog("Resulting URL: ", url.absoluteString)
        
        self.init(url: url, cachePolicy: .returnCacheDataElseLoad)
        self.httpMethod = method.rawValue
        
        if method == .POST {
            wplog("Trying to append data...")
            guard let bodyData = try? JSONSerialization.data(withJSONObject: data) else {
                wplog("Appending data failed!")
                return nil
            }
            self.httpBody = bodyData
            wplog("Appending data succeeded.")
        }
    }
}

extension Array {
    static func +(lhs: [Element], rhs: Element) -> [Element] {
        var lhs = lhs
        lhs.append(rhs)
        return lhs
    }
}
