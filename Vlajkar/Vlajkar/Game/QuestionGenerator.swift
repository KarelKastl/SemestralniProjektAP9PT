import Foundation

/// Vybírá země a skládá otázky (F2).
nonisolated enum QuestionGenerator {
    /// Země, které se v daném režimu smí objevit.
    static func eligibleCountries(_ countries: [QuizCountry], config: GameConfig) -> [QuizCountry] {
        countries.filter { country in
            guard !config.unMembersOnly || country.isUNMember else { return false }
            switch config.mode {
            case .flag: return country.hasFlag
            case .capital: return country.capital?.isEmpty == false
            case .population: return country.population > 0
            }
        }
    }

    static func makeQuestions(
        from countries: [QuizCountry],
        config: GameConfig,
        count: Int = 10,
        using generator: inout some RandomNumberGenerator
    ) -> [QuizQuestion] {
        let eligible = eligibleCountries(countries, config: config)
        let subjects = eligible.filter { config.region == .world || $0.region == config.region.rawValue }
        let subjectsShuffled = stableOrder(subjects).shuffled(using: &generator)

        switch config.mode {
        case .population:
            return makePopulationQuestions(from: subjectsShuffled, count: count, using: &generator)
        case .flag, .capital:
            let optionCount = max(config.optionCount, 2)
            return Array(subjectsShuffled.prefix(count)).enumerated().compactMap { index, subject in
                let options = makeOptions(
                    for: subject,
                    in: eligible,
                    mode: config.mode,
                    optionCount: optionCount,
                    using: &generator
                )
                guard options.count >= 2 else { return nil }
                return QuizQuestion(id: index, mode: config.mode, subject: subject, options: options)
            }
        }
    }

    /// Řazení podle kódu, aby výsledek se stejným semínkem nezávisel na pořadí z databáze.
    private static func stableOrder(_ countries: [QuizCountry]) -> [QuizCountry] {
        countries.sorted { $0.code < $1.code }
    }

    private static func title(of country: QuizCountry, mode: GameMode) -> String {
        mode == .capital ? (country.capital ?? "") : country.name
    }

    private static func makeOptions(
        for subject: QuizCountry,
        in eligible: [QuizCountry],
        mode: GameMode,
        optionCount: Int,
        using generator: inout some RandomNumberGenerator
    ) -> [QuizOption] {
        let subjectTitle = title(of: subject, mode: mode)
        var usedTitles: Set<String> = [subjectTitle]
        var options = [QuizOption(country: subject, title: subjectTitle)]

        // F2: nejdřív země ze stejného regionu, zbytek doplní celý svět.
        let others = stableOrder(eligible.filter { $0.code != subject.code })
        let sameRegion = others.filter { $0.region == subject.region }.shuffled(using: &generator)
        let elsewhere = others.filter { $0.region != subject.region }.shuffled(using: &generator)

        for country in sameRegion + elsewhere where options.count < optionCount {
            let candidate = title(of: country, mode: mode)
            // Dvě země můžou mít stejně pojmenované hlavní město, možnosti ale musí být různé.
            guard usedTitles.insert(candidate).inserted else { continue }
            options.append(QuizOption(country: country, title: candidate))
        }
        return options.shuffled(using: &generator)
    }

    private static func makePopulationQuestions(
        from countries: [QuizCountry],
        count: Int,
        using generator: inout some RandomNumberGenerator
    ) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        var remaining = countries

        while questions.count < count, !remaining.isEmpty {
            let first = remaining.removeFirst()
            guard let index = remaining.firstIndex(where: { $0.population != first.population }) else { break }
            let second = remaining.remove(at: index)
            let subject = first.population > second.population ? first : second
            let options = [first, second]
                .map { QuizOption(country: $0, title: $0.name) }
                .shuffled(using: &generator)
            questions.append(QuizQuestion(id: questions.count, mode: .population, subject: subject, options: options))
        }
        return questions
    }
}
