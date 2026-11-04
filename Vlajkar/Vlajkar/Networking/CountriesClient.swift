import Foundation

/// Zdroj dat o zemích. Testy a spouštěcí přepínače ho nahrazují zástupcem.
nonisolated protocol CountriesFetching: Sendable {
    func fetchCountries() async throws -> [CountryDTO]
    func fetchFlag(from url: URL) async throws -> Data
}

nonisolated enum CountriesError: LocalizedError, Equatable {
    case noConnection
    case missingKey
    case unauthorized
    case rateLimited
    case server(Int)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .noConnection: "Nepodařilo se připojit k internetu. Zkontrolujte připojení a zkuste to znovu."
        case .missingKey: "V aplikaci chybí klíč k datové službě."
        case .unauthorized: "Datová služba odmítla klíč aplikace."
        case .rateLimited: "Datová služba je teď přetížená nebo byl vyčerpán měsíční limit. Zkuste to později."
        case .server: "Datová služba je dočasně nedostupná. Zkuste to později."
        case .invalidData: "Datová služba vrátila neočekávaná data."
        }
    }
}

/// Klient REST Countries v5 (F1).
nonisolated struct CountriesClient: CountriesFetching {
    typealias Transport = @Sendable (URLRequest) async throws -> (Data, URLResponse)

    static let endpoint = URL(string: "https://api.restcountries.com/countries/v5")!
    static let pageSize = 100
    static let fields = [
        "codes.alpha_3", "codes.alpha_2", "names.common", "names.official", "names.translations.ces",
        "capitals", "region", "subregion", "population", "memberships.un", "coordinates", "flag.url_png",
    ].joined(separator: ",")

    let apiKey: String?
    let transport: Transport

    init(
        apiKey: String?,
        transport: @escaping Transport = { try await URLSession.shared.data(for: $0) }
    ) {
        self.apiKey = apiKey
        self.transport = transport
    }

    func fetchCountries() async throws -> [CountryDTO] {
        guard let apiKey, !apiKey.isEmpty else { throw CountriesError.missingKey }

        var countries: [CountryDTO] = []
        var offset = 0
        var more = true
        // F1: stránkujeme, dokud API hlásí další záznamy. Plán zdarma vrací nejvýš 100 na stránku.
        while more {
            let page = try await fetchPage(offset: offset, apiKey: apiKey)
            countries += page.data.objects
            more = page.data.meta.more && !page.data.objects.isEmpty
            offset += page.data.objects.count
        }
        return countries
    }

    func fetchFlag(from url: URL) async throws -> Data {
        let (data, _) = try await send(URLRequest(url: url))
        return data
    }

    static func pageRequest(offset: Int, apiKey: String) -> URLRequest {
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(pageSize)),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "response_fields", value: fields),
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func fetchPage(offset: Int, apiKey: String) async throws -> CountriesPage {
        let (data, _) = try await send(Self.pageRequest(offset: offset, apiKey: apiKey))
        do {
            return try JSONDecoder().decode(CountriesPage.self, from: data)
        } catch {
            throw CountriesError.invalidData
        }
    }

    private func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        let result: (Data, URLResponse)
        do {
            result = try await transport(request)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw CountriesError.noConnection
        }
        guard let response = result.1 as? HTTPURLResponse else { throw CountriesError.invalidData }
        switch response.statusCode {
        case 200 ..< 300: return result
        case 401, 403: throw CountriesError.unauthorized
        case 429: throw CountriesError.rateLimited
        default: throw CountriesError.server(response.statusCode)
        }
    }
}
