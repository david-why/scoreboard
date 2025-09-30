![ScoreBoard icon](public/icon200.png)

# ScoreBoard

ScoreBoard is a clean and sleek basketball scoreboard app. It is designed so that you can directly cast it from an iPad to a large TV screen at a basketball game.

_[See a video demo](public/record.mov)_

## Installation

[Try it out on Testflight here!](https://testflight.apple.com/join/1jC3NYqn) (if it doesn't work, then it's because Apple is still approving my build)

Alternatively, you can open this project in Xcode directly and run it from there.

## Technical details

This project uses SwiftUI... and it's kind of it!

One interesting detail (I guess) is this extension, which I like so much that I use it in virtually every SwiftUI project :p

```swift
extension View {
    @ViewBuilder
    func `if`(_ condition: @autoclosure () -> Bool, transform: (Self) -> some View) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
```
