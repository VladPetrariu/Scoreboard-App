//
//  WhatsTheScore_App.swift
//  WhatsTheScore?
//
//  Created by Vlad Petrariu on 2026-02-28.
//

import SwiftUI
import CoreData

@main
struct WhatsTheScore_App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
