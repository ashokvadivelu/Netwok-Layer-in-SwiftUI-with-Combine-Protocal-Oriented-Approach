//
//  NotificationViewModel.swift
//  APICallSample
//
//  Created by ashok on 13/06/20.
//  Copyright © 2020 ashok. All rights reserved.
//

import Foundation
import Combine
class EmployeeViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    var cancellableToken: AnyCancellable?
    let service: EmployeeServiceable

    func getEmployees() {
        cancellableToken = service.getallEmployees().mapError({ (error) -> Error in
            print(error.localizedDescription)
            self.state = .error(error)
            return error
        }).sink(receiveCompletion: { (completion) in
            print("Completion")
        }, receiveValue: { value in
            self.state = .loaded(value.data)
            print(value)
            print("Value in viewmodel")
        })
    }
    init(service: EmployeeServiceable) {
        self.service = service
    }
    convenience init(notificationService: EmployeeServiceable = EmployeeService()) {
        self.init(service: notificationService)
    }
}
extension EmployeeViewModel {
    enum State {
        case idle
        case loading
        case loaded([EmployeeModel])
        case error(Error)
    }
}
