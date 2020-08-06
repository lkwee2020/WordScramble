//
//  ContentView.swift
//  WordScramble
//
//  Created by Lauren Kwee on 8/5/20.
//  Copyright © 2020 Lauren Kwee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var errorShowing = false
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
    
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Text("Your score is \(calculateScore())")
                .padding()
            }
        .navigationBarTitle(rootWord)
            .navigationBarItems(leading: Button(action: startGame){
                Text("New word")
            })
        .onAppear(perform: startGame)
            .alert(isPresented: $errorShowing) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original.")
            return
        }
        
        guard isReal(word: answer) else{
            wordError(title: "Word not recognized", message: "You can't just make up words, you know")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Word not possible", message: "You have to use the give letters, duhhh")
            return
        }
        
        guard isTooShort(word: answer) else{
            wordError(title: "Word too short", message: "Use words that are longer than three letters.")
            return
        }
        
        guard isOriginalWord(word: answer) else{
            wordError(title: "Word is root word", message: "Make up your own word bruh")
            return
        }
            
        usedWords.insert(answer, at:0)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?
                String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords.removeAll()
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            }
            else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        errorShowing = true
    }
    
    func isTooShort(word: String) -> Bool{
        return word.count > 2
    }
    
    func isOriginalWord(word: String) -> Bool{
        return word != rootWord
    }
    
    func calculateScore() -> Int {
        var score = 0
        for word in usedWords{
            score += word.count
        }
        return score
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
