//
//  BasketballBoard.swift
//  ScoreBoard
//
//  Created by David Wang on 2025/9/17.
//

import SwiftUI

@Observable
final class BasketballPlayer: Identifiable, Equatable {
    let id = UUID()
    var number: Int
    var fouls: Int = 0
    
    init(number: Int) {
        self.number = number
    }
    
    static func == (lhs: BasketballPlayer, rhs: BasketballPlayer) -> Bool {
        lhs.id == rhs.id
    }
}

@Observable
final class BasketballTeam: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
    var score: Int = 0
    var players: [BasketballPlayer] = []
    
    init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
    
    static func == (lhs: BasketballTeam, rhs: BasketballTeam) -> Bool {
        lhs.id == rhs.id
    }
    
    var displayScore: String {
        "\(score < 10 ? "0" : "")\(score)"
    }
    
    var fouls: Int {
        players.map(\.fouls).reduce(0, +)
    }
}

fileprivate func digitsFont(size: CGFloat = 1) -> Font {
    return .custom("DSEG7 Classic", size: size * UIScreen.main.nativeBounds.width / 17).weight(.bold)
}

fileprivate let largeDigitsFont = digitsFont(size: 1.2)

fileprivate func titleFont(size: CGFloat = 1) -> Font {
    .system(size: size * UIScreen.main.nativeBounds.width / 27, weight: .bold)
}

fileprivate let smallTitleFont = titleFont(size: 0.85)

struct BasketballBoard: View {
    private let borderWidth: CGFloat = 5
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var timerInterval: TimeInterval = 0.0
    @State var countdownMinutes = 20
    @State var countdownSeconds = 0
    @State var timerRunning = false
    
    @State var team1 = BasketballTeam(name: "HOME", color: .red)
    @State var team2 = BasketballTeam(name: "GUEST", color: .blue)
    @State var period: Int = 1
    
    @State var foulPlayer: BasketballPlayer? = nil
    
    @State var isNextPeriodDialogShown = false
    @State var isChangingTimer = false
    
    @State var editingTeam: BasketballTeam? = nil
    @State var isAddingPlayer = false
    @State var addingPlayerNumbers = ""
    @State var isDeletingPlayer = false
    @State var deletingPlayer: BasketballPlayer? = nil
    
    var body: some View {
        VStack {
            timerView
                .padding(.bottom, -48)
            
            ZStack {
                HStack {
                    BasketballTeamView(team: team1)
                    Spacer()
                    BasketballTeamView(team: team2)
                }
                VStack {
                    Text("PERIOD")
                        .font(smallTitleFont)
                    Text("\(period)")
                        .font(digitsFont())
                        .foregroundStyle(.orange)
                        .onTapGesture(perform: nextPeriod)
                }
                .offset(y: 32)
            }
            .padding(.horizontal, 48)

            Rectangle()
                .frame(height: borderWidth)
                .padding(.top, 48)
            
            Spacer()
            
            if let editingTeam {
                VStack {
                    HStack {
                        VStack {
                            teamNameView(for: editingTeam)
                                .onTapGesture(perform: closeTeamSheet)
                                .onLongPressGesture(perform: addPlayer)
                        }
                        if !editingTeam.players.isEmpty {
                            LazyVGrid(columns: Array(repeating: .init(), count: 5), spacing: 20) {
                                ForEach(editingTeam.players) { player in
                                    Text("\(player.number)")
                                        .font(titleFont(size: 0.6))
                                        .onTapGesture {
                                            addFoul(player: player)
                                        }
                                        .onLongPressGesture {
                                            askDeletePlayer(player)
                                        }
                                }
                            }
                            .frame(maxWidth: 800)
                        }
                        if editingTeam.players.isEmpty {
                            Text("NO PLAYERS")
                                .font(titleFont(size: 0.6))
                        }
                    }
                }
                .padding(.horizontal, 48)
                .alert("Add player", isPresented: $isAddingPlayer, presenting: editingTeam) { team in
                    TextField("Player numbers", text: $addingPlayerNumbers)
                    Button("Add") {
                        doAddPlayer()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: { _ in
                    Text("Please enter player numbers, separated by a comma.")
                }
            } else {
                HStack {
                    VStack {
                        Text("FOULS")
                            .font(smallTitleFont)
                        Text("\(team1.fouls)")
                            .font(digitsFont())
                            .foregroundStyle(.orange)
                            .onTapGesture {
                                openTeamSheet(team1)
                            }
                        Text("WON")
                            .font(smallTitleFont)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("PLAYER")
                            .font(smallTitleFont)
                        Text("\(displayPlayerFoul)")
                            .font(digitsFont())
                            .foregroundStyle(.red)
                            .onLongPressGesture(perform: undoFoul)
                        Text("GAME")
                            .font(smallTitleFont)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("FOULS")
                            .font(smallTitleFont)
                        Text("\(team2.fouls)")
                            .font(digitsFont())
                            .foregroundStyle(.orange)
                            .onTapGesture {
                                openTeamSheet(team2)
                            }
                        Text("WON")
                            .font(smallTitleFont)
                    }
                }
                .padding(.horizontal, 48)
            }
            
            Spacer()
        }
        .border(Color.primary, width: borderWidth)
        .padding(.horizontal, 12)
        .alert("Next period?", isPresented: $isNextPeriodDialogShown) {
            Button("Yes", role: .destructive, action: confirmNextPeriod)
        } message: {
            Text("This will reset the timer.")
        }
        .onReceive(timer, perform: onTimerTick)
        .statusBarHidden()
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        .defersSystemGestures(on: .bottom)
        .preferredColorScheme(.dark)
        .alert("Delete player", isPresented: $isDeletingPlayer, presenting: deletingPlayer) { player in
            Button("Delete", role: .destructive) {
                doDeletePlayer(player)
            }
            Button("Cancel", role: .cancel) {}
        } message: { player in
            Text("Are you sure you want to delete player #\(player.number)? This cannot be undone.")
        }
    }
    
    var timerView: some View {
        Button("\(displayTimer)") {}
            .foregroundStyle(.orange)
            .font(largeDigitsFont)
            .contentShape(Rectangle())
            .padding(32)
            .border(.white, width: borderWidth)
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        changeTimer()
                    }
            )
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        toggleTimer()
                    }
            )
//            .onLongPressGesture(perform: changeTimer)
//            .onTapGesture(perform: toggleTimer)
            .popover(isPresented: $isChangingTimer, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                timerPopoverView
            }
    }
    
    @ViewBuilder var timerPopoverView: some View {
        HStack {
            Picker("Minutes", selection: $countdownMinutes) {
                ForEach(0...60, id: \.self) { i in
                    Text("\(i)").tag(i)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 150)
            Picker("Seconds", selection: $countdownSeconds) {
                ForEach(0...59, id: \.self) { i in
                    Text("\(i)").tag(i)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 150)
        }
        Button("Reset", role: .destructive, action: resetTimer)
            .padding(.bottom, 10)
    }
    
    // MARK: - Computed state
    
    var players: [BasketballPlayer] {
        team1.players + team2.players
    }
    
    var countdownInterval: TimeInterval {
        TimeInterval(countdownMinutes * 60 + countdownSeconds)
    }
    
    // MARK: - Display state
    
    var displayTimer: String {
        let interval = timerInterval > 0 ? timerInterval : countdownInterval
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var displayPlayerFoul: String {
        if let foulPlayer {
            "\(foulPlayer.number)  :  \(foulPlayer.fouls)"
        } else {
            "00  :  0"
        }
    }
    
    // MARK: - Events
    
    func onTimerTick(_: Date) {
        if timerRunning {
            timerInterval -= 1
            if timerInterval <= 0 {
                timerRunning = false
            }
        }
    }
    
    // MARK: - UI actions
    
    func nextPeriod() {
        isNextPeriodDialogShown = true
    }
    
    func confirmNextPeriod() {
        period += 1
        timerInterval = 0
    }
    
    func changeTimer() {
        isChangingTimer = true
    }
    
    func toggleTimer() {
        timerRunning.toggle()
        if timerInterval <= 0 {
            timerInterval = countdownInterval
        }
    }
    
    func resetTimer() {
        timerInterval = 0
    }
    
    func addPlayer() {
        addingPlayerNumbers = ""
        isAddingPlayer = true
    }
    
    func doAddPlayer() {
        if let editingTeam {
            let playerNumberStrings = addingPlayerNumbers.split(separator: ",").map(String.init)
            let playerNumbers = playerNumberStrings.compactMap(Int.init)
            let players = playerNumbers.map(BasketballPlayer.init)
            editingTeam.players.append(contentsOf: players)
        }
        isAddingPlayer = false
    }
    
    func addFoul(player: BasketballPlayer) {
        player.fouls += 1
        foulPlayer = player
        editingTeam = nil
    }
    
    func askDeletePlayer(_ player: BasketballPlayer) {
        deletingPlayer = player
        isDeletingPlayer = true
    }
    
    func closeTeamSheet() {
        editingTeam = nil
    }
    
    func openTeamSheet(_ team: BasketballTeam) {
        editingTeam = team
    }
    
    func doDeletePlayer(_ player: BasketballPlayer) {
        if let editingTeam {
            editingTeam.players.removeAll { $0 === player }
        }
    }
    
    func undoFoul() {
        if let foulPlayer {
            foulPlayer.fouls -= 1
            self.foulPlayer = nil
        }
    }
}

struct BasketballTeamView: View {
    @Bindable var team: BasketballTeam
    
    @State private var isScoreMenuPresented = false
    @State private var isPopupPresented = false
    
    var body: some View {
        VStack {
            teamNameView(for: team)
                .padding(.bottom, 8)
                .onLongPressGesture(perform: openTeamPopup)
                .popover(isPresented: $isPopupPresented, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                    Grid {
                        GridRow {
                            Text("Name")
                                .frame(width: 100)
                                .bold()
                            TextField("Name", text: $team.name)
                                .frame(width: 200)
                        }
                        GridRow {
                            Text("Color")
                                .frame(width: 100)
                                .bold()
                            HStack {
                                ColorPicker("Color", selection: $team.color)
                                    .labelsHidden()
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                }
            Text("\(team.displayScore)")
                .font(largeDigitsFont)
                .foregroundStyle(.red)
                .onTapGesture(perform: incrementScore)
                .onTapGesture(count: 2, perform: incrementScore2)
                .onTapGesture(count: 3, perform: incrementScore3)
                .onLongPressGesture(perform: openScoreMenu)
                .popover(isPresented: $isScoreMenuPresented, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                    Stepper("Score", value: $team.score, in: 0...Int.max)
                        .labelsHidden()
                        .padding()
                }
        }
    }
    
    // MARK: - UI actions
    
    func openTeamPopup() {
        isPopupPresented = true
    }
    
    func incrementScore() {
        team.score += 1
    }
    
    func incrementScore2() {
        team.score += 2
    }
    
    func incrementScore3() {
        team.score += 3
    }

    func openScoreMenu() {
        isScoreMenuPresented = true
    }
}

@ViewBuilder fileprivate func teamNameView(for team: BasketballTeam, font: Font? = nil) -> some View {
    Text(" \(team.name) ")
        .font(font ?? titleFont())
        .background(in: Rectangle())
        .backgroundStyle(team.color)
}

#Preview {
    BasketballBoard()
}
