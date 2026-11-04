import SwiftData
import SwiftUI

/// Herní obrazovka. Stav je v `GameEngine`, view jen zobrazuje a posílá akce (F3).
struct GameView: View {
    let engine: GameEngine

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext
    @State private var isConfirmingExit = false

    private static let nextButtonID = "game.next"

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                // Velké písmo smí scrollovat, po odpovědi se Další samo posune na obrazovku.
                ScrollViewReader { proxy in
                    ScrollView { content }
                        .onChange(of: engine.state) { _, state in
                            guard state.isAnswered else { return }
                            withAnimation { proxy.scrollTo(Self.nextButtonID, anchor: .bottom) }
                        }
                }
            } else {
                content
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(engine.config.mode.title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Ukončit") { isConfirmingExit = true }
            }
        }
        .confirmationDialog("Ukončit hru?", isPresented: $isConfirmingExit, titleVisibility: .visible) {
            Button("Ukončit hru", role: .destructive) { dismiss() }
            // Bez role `.cancel`, ta by na iPhonu tlačítko skryla.
            Button("Pokračovat") {}
        } message: {
            Text("Rozehraná hra se neuloží.")
        }
        .sensoryFeedback(trigger: engine.state) { _, state in
            switch state {
            case .waiting: nil
            case .correct: .success
            case .wrong: .error
            }
        }
        .task(id: engine.currentIndex) { await runTimer() }
    }

    private var content: some View {
        VStack(spacing: 12) {
            GameHeader(engine: engine)
            if let question = engine.currentQuestion {
                QuestionPrompt(question: question, isCompact: false)
                    .frame(maxWidth: .infinity, maxHeight: dynamicTypeSize.isAccessibilitySize ? nil : .infinity)
                OptionsGrid(question: question, state: engine.state) { option in
                    record(engine.answer(option.id))
                }
                Button {
                    engine.next()
                } label: {
                    // Šířka je v popisku, delší text tak s velkým písmem nemění zásah tlačítka.
                    Text(engine.isLastQuestion ? "Zobrazit výsledek" : "Další")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                // Tlačítko zůstává v rozložení, aby možnosti po odpovědi neposkočily.
                .opacity(engine.state.isAnswered ? 1 : 0)
                .disabled(!engine.state.isAnswered)
                .accessibilityHidden(!engine.state.isAnswered)
                .accessibilityIdentifier("game.next")
                .id(Self.nextButtonID)
            }
        }
        .padding(16)
    }

    private func record(_ outcome: AnswerOutcome?) {
        guard let outcome else { return }
        try? ProgressRecorder.record(outcome, in: modelContext)
    }

    private func runTimer() async {
        guard engine.config.usesTimer else { return }
        while !Task.isCancelled, !engine.state.isAnswered {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            record(engine.tick())
        }
    }
}

/// Ukazatel otázky, skóre, série a časovače.
private struct GameHeader: View {
    let engine: GameEngine

    var body: some View {
        // Velké písmo se s časovačem nevejde na jeden řádek, ukazatel pak přejde na dva.
        ViewThatFits(in: .horizontal) {
            HStack {
                progress
                Spacer()
                timer
                score
            }
            VStack(alignment: .leading, spacing: 2) {
                progress
                HStack {
                    timer
                    Spacer()
                    score
                }
            }
        }
        .font(.subheadline.weight(.medium))
        .lineLimit(1)
    }

    private var progress: some View {
        Text("Otázka \(engine.questionNumber)/\(engine.total)")
            .accessibilityIdentifier("game.progress")
    }

    @ViewBuilder
    private var timer: some View {
        if engine.config.usesTimer {
            Label(timerText, systemImage: "timer")
                .foregroundStyle(engine.remainingSeconds <= 5 ? .red : .primary)
                .monospacedDigit()
                .accessibilityIdentifier("game.timer")
        }
    }

    private var score: some View {
        HStack {
            Text("Skóre \(engine.score)")
                .accessibilityIdentifier("game.score")
            Text("Série \(engine.streak)")
                .accessibilityIdentifier("game.streak")
        }
    }

    private var timerText: String {
        engine.state == .wrong(selected: nil) ? "Čas vypršel" : "\(engine.remainingSeconds) s"
    }
}

/// Zadání otázky podle režimu.
struct QuestionPrompt: View {
    let question: QuizQuestion
    let isCompact: Bool

    var body: some View {
        switch question.mode {
        case .flag:
            FlagView(code: question.subject.code)
                .frame(maxWidth: .infinity, minHeight: 110)
                // Popisek nesmí prozradit zemi (F8).
                .accessibilityElement()
                .accessibilityLabel("Vlajka, hádej zemi")
                .accessibilityIdentifier("game.flag")
        case .capital:
            VStack(spacing: 8) {
                Text("Hlavní město země")
                    .foregroundStyle(.secondary)
                Text(question.subject.name)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .accessibilityIdentifier("game.country")
            }
        case .population:
            Text("Která země má víc obyvatel?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("game.question")
        }
    }
}

/// Mřížka možností 2×2 nebo 2×3 bez pevných rozměrů.
private struct OptionsGrid: View {
    let question: QuizQuestion
    let state: QuestionState
    let onSelect: (QuizOption) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var rows: [[QuizOption]] {
        if question.options.count == 2 { return question.options.map { [$0] } }
        return stride(from: 0, to: question.options.count, by: 2).map {
            Array(question.options[$0 ..< min($0 + 2, question.options.count)])
        }
    }

    var body: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(rows, id: \.first?.id) { row in
                GridRow {
                    ForEach(row) { option in
                        OptionButton(
                            option: option,
                            index: question.options.firstIndex(of: option) ?? 0,
                            question: question,
                            state: state,
                            action: { onSelect(option) }
                        )
                    }
                }
            }
        }
        .frame(maxHeight: dynamicTypeSize.isAccessibilitySize ? nil : 260)
    }
}

private struct OptionButton: View {
    let option: QuizOption
    let index: Int
    let question: QuizQuestion
    let state: QuestionState
    let action: () -> Void

    private var isCorrectOption: Bool { option.id == question.correctOptionID }

    private var isSelected: Bool {
        switch state {
        case .waiting: false
        case let .correct(selected): selected == option.id
        case let .wrong(selected): selected == option.id
        }
    }

    private var fill: Color {
        guard state.isAnswered else { return Color(.secondarySystemBackground) }
        if isCorrectOption { return .green.opacity(0.35) }
        return isSelected ? .red.opacity(0.35) : Color(.secondarySystemBackground)
    }

    private var resultSymbol: String? {
        guard state.isAnswered else { return nil }
        if isCorrectOption { return "checkmark.circle.fill" }
        return isSelected ? "xmark.circle.fill" : nil
    }

    private var resultValue: String {
        guard state.isAnswered else { return "" }
        if isCorrectOption { return "Správná odpověď" }
        return isSelected ? "Špatná odpověď" : ""
    }

    @ViewBuilder
    private var symbol: some View {
        if let resultSymbol {
            Image(systemName: resultSymbol)
                .foregroundStyle(isCorrectOption ? .green : .red)
                .accessibilityHidden(true)
        }
    }

    private var title: some View {
        Text(option.title)
            .font(.headline)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if question.mode == .population, option.country.hasFlag {
                    FlagView(code: option.id, pixelWidth: 240)
                        .frame(maxWidth: 120, maxHeight: 64)
                        .accessibilityHidden(true)
                }
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 6) {
                        symbol
                        title.fixedSize(horizontal: true, vertical: false)
                    }
                    VStack(spacing: 2) {
                        symbol
                        title
                    }
                }
                // F4: po odpovědi ukáže obě čísla.
                if question.mode == .population, state.isAnswered {
                    Text(Formatting.number(option.country.population))
                        .font(.subheadline)
                        .monospacedDigit()
                        .accessibilityIdentifier("game.population.\(index)")
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(fill, in: RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(OptionButtonStyle())
        .disabled(state.isAnswered)
        .accessibilityValue(resultValue)
        .accessibilityIdentifier("game.option.\(index)")
    }
}

/// Vlastní styl: výchozí styl by zodpovězené možnosti ztlumil a výsledek by nebyl čitelný.
private struct OptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        GameView(engine: PreviewData.engine)
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
#endif
