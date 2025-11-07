//
//  CluckCascadeApp.swift
//  CluckCascade
//
//  Created by Дионисий Коневиченко on 07.11.2025.
//

import SwiftUI

@main
struct CluckCascadeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
