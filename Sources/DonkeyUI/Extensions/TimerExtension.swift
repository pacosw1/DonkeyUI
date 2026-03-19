//
//  TimerExtension.swift
//  BuildUp
//
//  Created by paco on 31/08/22.
//

import SwiftUI

@MainActor
class TimerModel: ObservableObject {
    var id: UUID = UUID()
    var timer: Timer? = nil
    @Published var running: Bool = false
    var action: (() -> Bool)?
    
    func initTimer(interval: Double, action: @escaping () -> Bool) {
        self.action = action
        timer = Timer(timeInterval: interval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    func startTimer(interval: Double, action: @escaping () -> Bool) {
            if self.running || timer !== nil {
                return
            }
            
            self.initTimer(interval: interval, action: action)
        RunLoop.current.add(self.timer!, forMode: .common)
            running = true
    }
     
    func stopTimer() {
        timer?.invalidate()
        running = false
        timer = nil
    }
    
    @objc func fireTimer() {
        let done = self.action!()

        if done {
            self.stopTimer()
        }
    }
}

struct TimerExtension: ViewModifier {
    var lastUpdate: Int64
    var interval: Double
    var action: () -> Bool
    @StateObject private var model = TimerModel()
    
    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .onChange(of: lastUpdate) {
            model.startTimer(interval: interval, action: action)
        }
    }
}

extension View {
    func timer(interval: Double = 1.0, lastUpdate: Int64, onFire: @escaping () -> Bool) -> some View {
        modifier(TimerExtension( lastUpdate: lastUpdate, interval: interval, action: onFire))
    }
}
