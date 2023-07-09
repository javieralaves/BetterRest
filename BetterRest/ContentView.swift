//
//  ContentView.swift
//  BetterRest
//
//  Created by Javier Alaves on 8/7/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var sleepResults: String {
        
        do {
            let config = MLModelConfiguration()
            // Loading the model might fail, so we use a do, catch
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            // Date they should go to sleep
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
            // More code here
        } catch {
            return "There was an error"
        }
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("When you want to wake up?")
                                .font(.headline)
                            
                            DatePicker("Please select a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Desired amount of sleep")
                                .font(.headline)
                            
                            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Daily coffee intake")
                                .font(.headline)
                            
                            Picker("Daily coffee intake", selection: $coffeeAmount) {
                                ForEach((1...20), id: \.self) {
                                    Text("\($0)")
                                }
                            }
                        }
                    }
                    
                    Section {
                        VStack(alignment: .center, spacing: 8) {
                            Text("Recommended sleep")
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            Text(sleepResults)
                                .font(.title)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .navigationTitle("BetterRest")
            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
