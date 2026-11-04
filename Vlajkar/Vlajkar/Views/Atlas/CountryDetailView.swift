import MapKit
import SwiftData
import SwiftUI

/// Detail země s mapou (F6).
struct CountryDetailView: View {
    let country: Country

    private var coordinate: CLLocationCoordinate2D {
        // Mapa neumí střed přesně na pólu (Antarktida má šířku -90).
        CLLocationCoordinate2D(latitude: min(max(country.latitude, -80), 80), longitude: country.longitude)
    }

    var body: some View {
        List {
            Section {
                FlagView(code: country.code)
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .accessibilityElement()
                    .accessibilityLabel("Vlajka země \(country.nameCS)")
                    .accessibilityIdentifier("detail.flag")
                    .listRowBackground(Color.clear)
            }
            Section("Základní údaje") {
                LabeledContent("Oficiální název", value: country.officialNameCS)
                LabeledContent("Hlavní město", value: country.capital ?? "Nemá")
                LabeledContent("Region", value: RegionFilter.title(forAPIRegion: country.region))
                if let subregion = country.subregion {
                    LabeledContent("Subregion", value: subregion)
                }
                LabeledContent("Počet obyvatel", value: Formatting.number(country.population))
            }
            Section("Moje statistika") {
                LabeledContent("Uhodnuto", value: String(country.correctCount))
                LabeledContent("Špatně", value: String(country.wrongCount))
                if let discoveredAt = country.discoveredAt {
                    LabeledContent("Objeveno", value: Formatting.date(discoveredAt))
                }
            }
            Section("Mapa") {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
                ))) {
                    Marker(country.nameCS, coordinate: coordinate)
                }
                .aspectRatio(1.4, contentMode: .fit)
                .accessibilityLabel("Mapa země \(country.nameCS)")
                .accessibilityIdentifier("detail.map")
                .listRowInsets(EdgeInsets())
            }
        }
        .navigationTitle(country.nameCS)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CountryDetailView(country: Country(
            code: "CZE",
            nameCS: "Česko",
            officialNameCS: "Česká republika",
            capital: "Prague",
            region: "Europe",
            subregion: "Central Europe",
            population: 10_903_655,
            isUNMember: true,
            latitude: 49.75,
            longitude: 15.5,
            flagURL: ""
        ))
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
