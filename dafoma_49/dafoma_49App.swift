//
//  dafoma_49App.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

@main
struct dafoma_49App: App {
    let persistenceController = DataService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
