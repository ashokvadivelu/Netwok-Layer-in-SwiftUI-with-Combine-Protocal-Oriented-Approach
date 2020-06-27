//
//  EndPoint.swift
//  APICallSample
//
//  Created by Ashok on 09/06/20.
//  Copyright © 2020 ashok. All rights reserved.
//

import Foundation
import Combine
enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
protocol EndPoint {
    var path: String { get }
    var method: HttpMethod { get }
    var header: [Header] { get }
    var body: Data? { get }
    var baseUrl: String { get }
    var bgQueue: DispatchQueue { get}
}
enum error: Error {
    typealias RawValue = String

    case invalidURL
}
//Header
struct Header {
    let key: String
    let value: String
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

extension EndPoint {
    var body: Data? {
        return nil
    }
    var header: [Header] {
        return self.standardHeaders
    }
    var baseUrl: String {
        return "http://dummy.restapiexample.com/"
    }
    var bgQueue: DispatchQueue {
        return DispatchQueue.global()
    }
    var buildRequest: URLRequest {
        guard let url = URL(string: baseUrl + path) else {
            fatalError("Invalid url")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        let headers = header + standardHeaders
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        request.httpBody =  body
        return request
    }

    func makeRequest<T: Decodable>() -> AnyPublisher<Response<T>, Error> {
        let urlRequest = buildRequest
        let session = sessionConfiguration
        return session
            .dataTaskPublisher(for: urlRequest)
            .subscribe(on: bgQueue)
            .tryMap { result -> Response<T> in
                let value = try JSONDecoder().decode(T.self, from: result.data)
                print("ad")
                return Response(value: value, response: result.response)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()

    }
    var sessionConfiguration: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }
    private var standardHeaders: [Header] {
        let jsonHeader = Header(key: HttpFieldType.contentType, value: HttpMimeType.json)
        return [jsonHeader]
    }
}
struct Response<T> {
    let value: T
    let response: URLResponse
}
