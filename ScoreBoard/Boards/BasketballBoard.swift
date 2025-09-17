//
//  BasketballBoard.swift
//  ScoreBoard
//
//  Created by David Wang on 2025/9/17.
//

import SwiftUI

struct BasketballPlayer: Identifiable {
    let id = UUID()
    var number: Int
    var fouls: Int
}

struct BasketballTeam {
    var name: String
    var color: Color
    var score: Int = 0
    var fouls: Int = 0
    var players: [BasketballPlayer] = []
    
    var displayScore: String {
        "\(score < 10 ? "0" : "")\(score)"
//        "\(score)"
    }
}

struct BasketballBoard: View {
    private let borderWidth: CGFloat = 5
    
    @State var timerSeconds: TimeInterval = 0.0
    
    @State var team1 = BasketballTeam(name: "HOME", color: .red)
    @State var team2 = BasketballTeam(name: "GUEST", color: .blue)
    @State var period: Int = 1
    
    @State var foulPlayer: BasketballPlayer? = nil
    
    var body: some View {
        VStack {
            ZStack {
                Text("\(displayTimer)")
                    .foregroundStyle(.orange)
                    .font(digitsFont())
                    .padding(32)
                    .border(.white, width: borderWidth)
            }
            .padding(.bottom, -48)
            
            ZStack {
                HStack {
                    VStack {
                        Text(" \(team1.name) ")
                            .font(titleFont())
                            .background(in: Rectangle())
                            .backgroundStyle(team1.color)
                        Text("\(team1.displayScore)")
                            .font(digitsFont())
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text(" \(team2.name) ")
                            .font(titleFont())
                            .background(in: Rectangle())
                            .backgroundStyle(team2.color)
                        Text("\(team2.displayScore)")
                            .font(digitsFont())
                            .foregroundStyle(.red)
                    }
                }
                VStack {
                    Text("PERIOD")
                        .font(smallTitleFont)
                    Text("\(period)")
                        .font(digitsFont())
                        .foregroundStyle(.orange)
                }
                .offset(y: 32)
            }
            .padding(.horizontal, 48)

            Rectangle()
                .frame(height: borderWidth)
                .foregroundStyle(.white)
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
        .border(.white, width: borderWidth)
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
    
    // MARK: - Display state
    
    var displayTimer: String {
        let minutes = Int(timerSeconds) / 60
        let seconds = Int(timerSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var displayPlayerFoul: String {
        if let foulPlayer {
            "\(foulPlayer.number)  :  \(foulPlayer.fouls)"
        } else {
            "00  :  0"
        }
    }
}

#Preview {
    BasketballBoard()
}
