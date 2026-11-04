import SwiftData
import SwiftUI

/// Atlas objevených zemí (F6).
struct AtlasView: View {
    @Query(filter: #Predicate<Country> { $0.discoveredAt != nil })
    private var discovered: [Country]
    @Query(filter: #Predicate<Country> { $0.isUNMember })
    private var unMembers: [Country]

    @State private var searchText = ""
    @State private var region = RegionFilter.world

    private var filtered: [Country] {
        AtlasFilter.apply(discovered, search: searchText, region: region)
    }

    /// Ukazatel počítá členy OSN, aby nikdy nepřesáhl celkový počet.
    private var discoveredMembers: Int {
        discovered.filter(\.isUNMember).count
    }

    var body: some View {
        Group {
            if discovered.isEmpty {
                ContentUnavailableView(
                    "Atlas je zatím prázdný",
                    systemImage: "globe.europe.africa",
                    description: Text("Každá správně uhodnutá země se objeví tady.")
                )
            } else {
                list
            }
        }
        .navigationTitle("Atlas")
        .navigationDestination(for: Country.self) { country in
            CountryDetailView(country: country)
        }
    }

    private var list: some View {
        List {
            Section {
                Text("Objeveno \(discoveredMembers) / \(unMembers.count)")
                    .font(.headline)
                    .accessibilityIdentifier("atlas.counter")
                Picker("Region", selection: $region) {
                    ForEach(RegionFilter.allCases) { region in
                        Text(region.title).tag(region)
                    }
                }
                .accessibilityIdentifier("atlas.region")
            }
            Section {
                if filtered.isEmpty {
                    ContentUnavailableView.search
                } else {
                    ForEach(filtered) { country in
                        NavigationLink(value: country) {
                            AtlasRow(country: country)
                        }
                        .accessibilityIdentifier("atlas.row.\(country.code)")
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Hledat zemi")
    }
}

private struct AtlasRow: View {
    let country: Country

    var body: some View {
        HStack(spacing: 12) {
            FlagView(code: country.code, pixelWidth: 120)
                .frame(width: 44, height: 30)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(country.nameCS)
                if let capital = country.capital {
                    Text(capital)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AtlasView()
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
