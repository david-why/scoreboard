//
//  BasketballBoard.swift
//  ScoreBoard
//
//  Created by David Wang on 2025/9/17.
//

import SwiftUI

struct BasketballPlayer: Identifiable, Equatable {
    let id = UUID()
    var number: Int
    var fouls: Int
}

struct BasketballTeam: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
    var score: Int = 0
    var fouls: Int = 0
    var players: [BasketballPlayer] = []
    
    var displayScore: String {
        "\(score < 10 ? "0" : "")\(score)"
    }
}

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
    
    @State var changingScoreTeamID: BasketballTeam.ID? = nil
    @State var showingTeam: BasketballTeam? = nil
    
    var body: some View {
        VStack {
            ZStack {
                timerView
            }
            .padding(.bottom, -48)
            
            ZStack {
                HStack {
                    teamView(team1)
                    Spacer()
                    teamView(team2)
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
            
            HStack {
                VStack {
                    Text("FOULS")
                        .font(smallTitleFont)
                    Text("\(team1.fouls)")
                        .font(digitsFont())
                        .foregroundStyle(.orange)
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
                    Text("WON")
                        .font(smallTitleFont)
                }
            }
            .padding(.horizontal, 48)
            
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
    }
    
    var timerView: some View {
        Text("\(displayTimer)")
            .foregroundStyle(.orange)
            .font(digitsFont())
            .padding(32)
            .border(.white, width: borderWidth)
            .onLongPressGesture(perform: changeTimer)
            .onTapGesture(perform: toggleTimer)
            .popover(isPresented: $isChangingTimer, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                timerPopoverView
            }
    }
    
    @ViewBuilder var timerPopoverView: some View {
        HStack {
            Picker("Minutes", selection: $countdownMinutes) {
                ForEach(0...59, id: \.self) { i in
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
    
    @ViewBuilder func teamView(_ team: BasketballTeam) -> some View {
        VStack {
            Text(" \(team.name) ")
                .font(titleFont())
                .background(in: Rectangle())
                .backgroundStyle(team.color)
            Text("\(team.displayScore)")
                .font(digitsFont())
                .foregroundStyle(.red)
                .onTapGesture {
                    incrementTeamScore(team.id)
                }
                .onLongPressGesture {
                    openTeamScoreMenu(team.id)
                }
                .popover(isPresented: isChangingTeamScoreBinding(team.id), attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                    changeTeamScorePopoverView(team.id)
                }
        }
    }
    
    @ViewBuilder func changeTeamScorePopoverView(_ teamID: BasketballTeam.ID) -> some View {
        Stepper("Score", value: teamScoreBinding(teamID))
            .labelsHidden()
            .padding()
    }
    
    // MARK: - Fonts
    
    func digitsFont(size: CGFloat = 96) -> Font {
        .custom("DSEG7 Classic", size: size).weight(.bold)
    }
    
    func titleFont(size: CGFloat = 72) -> Font {
        .system(size: size, weight: .bold)
    }
    
    var smallTitleFont: Font {
        titleFont(size: 60)
    }
    
    // MARK: - Computed state
    
    var players: [BasketballPlayer] {
        team1.players + team2.players
    }
    
    var countdownInterval: TimeInterval {
        TimeInterval(countdownMinutes * 60 + countdownSeconds)
    }
    
    func isChangingTeamScoreBinding(_ teamID: BasketballTeam.ID) -> Binding<Bool> {
        Binding {
            changingScoreTeamID == teamID
        } set: {
            changingScoreTeamID = $0 ? teamID : nil
        }
    }
    
    func teamScoreBinding(_ teamID: BasketballTeam.ID) -> Binding<Int> {
        Binding {
            teamID == team1.id ? team1.score : team2.score
        } set: {
            if teamID == team1.id {
                team1.score = $0
            } else {
                team2.score = $0
            }
        }
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
    
    func incrementTeamScore(_ teamID: BasketballTeam.ID) {
        if teamID == team1.id {
            team1.score += 1
        } else if teamID == team2.id {
            team2.score += 1
        }
    }
    
    func openTeamScoreMenu(_ teamID: BasketballTeam.ID) {
        changingScoreTeamID = teamID
    }
}

#Preview {
    BasketballBoard()
}
