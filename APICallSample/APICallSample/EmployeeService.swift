//
//  NotificationService.swift
//  APICallSample
//
//  Created by ashok on 13/06/20.
//  Copyright © 2020 ashok. All rights reserved.
//

import Foundation
import Combine
protocol EmployeeServiceable {
    func getallEmployees() -> AnyPublisher<EmployeeResponse,Error>
}
public class EmployeeService: EmployeeServiceable {

    func getallEmployees() -> AnyPublisher<EmployeeResponse,Error> {
        let endPoint = EmployeeEndpoint.getallEmployee
        return endPoint.makeRequest().map(\.value).eraseToAnyPublisher()
    }
}

enum EmployeeEndpoint: EndPoint {
    case getallEmployee
    var path: String {
        switch self {
        case .getallEmployee:
            return "api/v1/employees"
        }
    }
    var method: HttpMethod {
        switch self {
        case .getallEmployee:
            return .get
        }
    }
    
    var bgQueue: DispatchQueue {
        let serialQueue = DispatchQueue(label: "api.serial.queue")
        return serialQueue

    }
    
}

struct EmployeeResponse: Codable {
    var status: String
    var data: [EmployeeModel]
}
struct EmployeeModel: Codable {
    var id: String
    var employee_name: String
    
}
