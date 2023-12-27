//
//  ContentView.swift
//  park_mod7_project
//
//  Created by Benjamin Park on 12/8/23.
//

import SwiftUI
import Foundation

func fetchQuote(completion: @escaping (String?, String?, Error?) -> Void) {
    let urlString = "https://zenquotes.io/api/random"
    
    guard let url = URL(string: urlString) else {
        completion(nil, nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(nil, nil, error)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(nil, nil, NSError(domain: "Invalid HTTP response", code: 0, userInfo: nil))
            return
        }
        
        if let responseData = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: String]], let quote = json.first {
                    if let text = quote["q"], let author = quote["a"] {
                        completion(text, author, nil)
                    } else {
                        completion(nil, nil, NSError(domain: "Invalid data format", code: 0, userInfo: nil))
                    }
                } else {
                    completion(nil, nil, NSError(domain: "Invalid JSON format", code: 0, userInfo: nil))
                }
            } catch {
                completion(nil, nil, error)
            }
        } else {
            completion(nil, nil, NSError(domain: "Empty response data", code: 0, userInfo: nil))
        }
    }
    
    task.resume()
}

struct ContentView: View {
    @State var total = ""
    @State var tipPercent = 15.0
    @State var quote = "Click on the button for a bonus \"tip\""
    @State var author = ""
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Text("Tip Calculator")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            }
            HStack {
                Text("$")
                TextField("Check Total", text: $total)
                .keyboardType(.decimalPad)
            }
            HStack {
                Slider(value: $tipPercent, in: 0...30, step: 1.0)
                Text("\(Int(tipPercent))")
                Text("%")
            }
            if let totalNum = Double(total) {
                let tipAmount = totalNum * tipPercent / 100
                Text("Tip Amount: $\(tipAmount, specifier: "%0.2f")")
                Text("Total Amount: $\(totalNum + tipAmount, specifier: "%0.2f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
            } else if total == "" {
                Text("Please enter an amount.")
            } else {
                Text("Your check total must be a numerical value.")
            }
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Text("Bonus Tip")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            }.padding(.top, 60.0)
            VStack {
                Text(quote)
                    .font(.title3)
                Text(author)
            }.padding(.vertical, 1.0)
            HStack {
                Button("Inspirational Quote") {
                    fetchQuote { (quoteText, authorName, error) in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else if let quoteText = quoteText, let authorName = authorName {
                            quote = quoteText
                            author = "-" + authorName
                        }
                    }
                }.padding(.top, 15.0)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onTapGesture {
            self.endTextEditing()
        }
    }
}

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}

#Preview {
    ContentView()
}
