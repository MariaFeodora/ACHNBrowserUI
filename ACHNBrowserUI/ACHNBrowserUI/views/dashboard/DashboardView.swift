//
//  DashboardView.swift
//  ACHNBrowserUI
//
//  Created by Eric Lewis on 4/18/20.
//  Copyright © 2020 Thomas Ricouard. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

struct Progress: UIViewRepresentable {
    let progress: Float
    
    func makeUIView(context: Context) -> UIProgressView {
        UIProgressView()
    }
    
    func updateUIView(_ uiView: UIProgressView, context: Context) {
        uiView.progress = progress
    }
}

struct DashboardView: View {
    @EnvironmentObject private var collection: CollectionViewModel
    @ObservedObject private var viewModel = DashboardViewModel()
    
    
    private func caughtIn(list: [Item]) -> Int {
        var caught = 0
        for critter in collection.critters {
            if list.contains(critter) {
                caught += 1
            }
        }
        return caught
    }
    
    private var numberOfFish: String {
        if !viewModel.fishes.isEmpty {
            return "\(caughtIn(list: viewModel.fishes))/\(viewModel.fishes.count)"
        }
        return "Loading..."
    }
    
    private var numberOfBugs: String {
        if !viewModel.bugs.isEmpty {
            return "\(caughtIn(list: viewModel.bugs))/\(viewModel.bugs.count)"
        }
        return "Loading..."
    }
    
    private var numberOfFossils: String {
        if !viewModel.fossils.isEmpty {
            return "\(caughtIn(list: viewModel.fossils))/\(viewModel.fossils.count)"
        }
        return "Loading..."
    }
    
    var body: some View {
        NavigationView {
            List {
                makeAvailableCritterSection()
                makeCritterCollectionProgressSection()
                makeTopTurnipSection()
                makeRecentNookazonListings()
            }
            .listStyle(GroupedListStyle())
            .onAppear(perform: viewModel.fetchListings)
            .onAppear(perform: viewModel.fetchIsland)
            .onAppear(perform: viewModel.fetchCritters)
            .navigationBarTitle("Dashboard",
                                displayMode: .inline)
        }
    }
}

extension DashboardView {
    func makeAvailableCritterSection() -> some View {
        Section(header: Text("Critters Active")) {
            HStack {
                Spacer()
                VStack {
                    Text(numberOfFish)
                        .font(.largeTitle)
                        .bold()
                    Text("Fish")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Text(numberOfBugs)
                        .font(.largeTitle)
                        .bold()
                    Text("Bugs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
    
    func makeCritterCollectionProgressSection() -> some View {
        Section(header: Text("Collection Progress")) {
            VStack(alignment: .leading) {
                if !viewModel.fishes.isEmpty &&
                    !viewModel.bugs.isEmpty &&
                    !viewModel.fossils.isEmpty {
                    Text("Fish")
                        .font(.subheadline)
                    Progress(progress: Float(caughtIn(list: viewModel.fishes)) / Float(viewModel.fishes.count))
                    Text("Bugs")
                        .font(.subheadline)
                    Progress(progress: Float(caughtIn(list: viewModel.bugs)) / Float(viewModel.bugs.count))
                    Text("Fossils")
                        .font(.subheadline)
                    Progress(progress: Float(caughtIn(list: viewModel.fossils)) / Float(viewModel.fossils.count))
                } else {
                    Text("Loading...")
                }
            }
            .padding(.bottom, 10)
            .padding(.top, 5)
        }
        .accentColor(.grass)
    }
    
    func makeTopTurnipSection() -> some View {
        Section(header: Text("Top Turnip Island")) {
            if viewModel.island == nil {
                Text("Loading...")
                    .foregroundColor(.secondary)
            }
            viewModel.island.map {
                TurnipCell(island: $0)
            }
        }
    }
    
    func makeRecentNookazonListings() -> some View {
        Section(header: Text("Recent Nookazon Listings")) {
            if viewModel.recentListings == nil {
                Text("Loading...")
                    .foregroundColor(.secondary)
            }
            viewModel.recentListings.map {
                ForEach($0) { listing in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            ItemImage(path: listing.img?.absoluteString, size: 25)
                                .frame(width: 25, height: 25)
                            Text(listing.name!)
                                .font(.headline)
                                .foregroundColor(.text)
                        }
                        ListingRow(listing: listing)
                    }
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
