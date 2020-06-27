//
//  ContentView.swift
//  APICallSample
//
//  Created by ashok on 09/06/20.
//  Copyright © 2020 ashok. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = EmployeeViewModel()
    var body: some View {
        content
            .onAppear {
                self.viewModel.getEmployees()
        }
    }

    private var content: some View {
        switch viewModel.state {
        case .idle:
            return ActivityIndicatorView().eraseToAnyView()
        case .loaded(let employees):
            return  EmployeeView(employees: employees).eraseToAnyView()
        case .loading:
            return  ActivityIndicatorView().eraseToAnyView()
        case .error(let error):
            return ErrorView(error: error).eraseToAnyView()
        }
    }
    // Idle State
    private var loadingView: some View {
        return  Text("Loading")
    }

}

// Error View
struct ErrorView: View {
    let error: Error
    var body: some View {
        VStack {
            Text(error.localizedDescription)
        }
    }
}


//Loaded View
struct EmployeeView: View {
    let employees: [EmployeeModel]
    var body: some View {
        List(employees, id: \.id) { employee in
            NavigationLink( destination: ContentView(),
                            label: { EmployeeListRow(rowName: employee.employee_name) }
            )
        }
    }
}
struct EmployeeListRow: View {
    let rowName: String
    var body: some View {
        ZStack {
            Text(rowName)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
