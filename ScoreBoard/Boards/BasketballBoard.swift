//
//  BasketballBoard.swift
//  ScoreBoard
//
//  Created by David Wang on 2025/9/17.
//

import SwiftUI

struct BasketballBoard: View {
    private let borderWidth: CGFloat = 5
    
    var body: some View {
        VStack {
            ZStack {
                Text("06:27")
                    .foregroundStyle(.orange)
                    .font(digitsFont())
                    .padding(32)
                    .border(.white, width: borderWidth)
            }
            .padding(.bottom, -48)
            
            HStack {
                VStack {
                    Text("HOME")
                        .font(titleFont())
                    Text("46")
                        .font(digitsFont())
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                VStack {
                    Text("PERIOD")
                        .font(smallTitleFont)
                    Text("3")
                        .font(digitsFont())
                        .foregroundStyle(.orange)
                }
                .offset(y: 32)
                
                Spacer()
                
                VStack {
                    Text("GUEST")
                        .font(titleFont())
                    Text("23")
                        .font(digitsFont())
                        .foregroundStyle(.red)
                }
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
                    Text("3")
                        .font(digitsFont())
                        .foregroundStyle(.orange)
                    Text("WON")
                        .font(smallTitleFont)
                }
                
                Spacer()
                
                VStack {
                    Text("PLAYER")
                        .font(smallTitleFont)
                    Text("55-1")
                        .font(digitsFont())
                        .foregroundStyle(.red)
                    Text("GAME")
                        .font(smallTitleFont)
                }
                
                Spacer()

                VStack {
                    Text("FOULS")
                        .font(smallTitleFont)
                    Text("2")
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
    
    func digitsFont(size: CGFloat = 96) -> Font {
        .custom("DSEG7 Classic", size: size).weight(.bold)
    }
    
    func titleFont(size: CGFloat = 72) -> Font {
        .system(size: size, weight: .bold)
    }
    
    var smallTitleFont: Font {
        titleFont(size: 60)
    }
}

#Preview {
    BasketballBoard()
}
