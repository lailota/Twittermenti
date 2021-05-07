//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetcount = 100
    
    let sentimentClassifier = try! TweetSentimenalClassifier(configuration: MLModelConfiguration.init())
    
    let swifter = Swifter(consumerKey: SecretValues.get().key, consumerSecret: SecretValues.get().secret)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    @IBAction func predictPressed(_ sender: Any) {
        
       fetchTweets()
        
    }
    
    
    func fetchTweets() {
        
        if let searchText = textField.text {
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetcount, tweetMode: .extended) { results, metadata in
                
                var tweets = [TweetSentimenalClassifierInput]()
                
                for i in 0..<self.tweetcount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimenalClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
            } failure: { error in
                print("There was an error with the Twitter API Request, \(error)")
            }
        }
    }
    
    
    func makePrediction(with tweets: [TweetSentimenalClassifierInput]) {
        
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for prediction in predictions {
                let sentiment = prediction.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            
            updateUI(with: sentimentScore)
            
        } catch {
            print("There was an error with making a prediction, \(error)")
        }
    }
    
    
    func updateUI(with sentimentScore: Int) {
        
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
    
}

