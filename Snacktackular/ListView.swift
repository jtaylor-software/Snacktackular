//
//  ListView.swift
//  Snacktackular
//
//  Created by Jeremy Taylor on 1/16/23.
//

import SwiftUI
import Firebase

struct ListView: View {
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Text("List items will go here")
        }
        .listStyle(.plain)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Sign Out") {
                    do {
                        try Auth.auth().signOut()
                        print("🪵➡️ Log out successful!")
                        dismiss()
                    } catch {
                        print("😡 ERROR: Could not sign out!")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    sheetIsPresented.toggle()
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
        .sheet(isPresented: $sheetIsPresented) {
            NavigationStack {
                SpotDetailView(spot: Spot())
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListView()
        }
    }
}
