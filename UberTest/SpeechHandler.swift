//
//  SpeechHandler.swift
//  UberTest
//
//  Created by Kyle Haptonstall on 3/12/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit

class SpeechHandler: NSObject, OEEventsObserverDelegate{
    
    var openEarsEventsObserver = OEEventsObserver()
    var lmPath: String!
    var dicPath: String!
    var words = [String]()

    func startSpeechHandler(){
        self.openEarsEventsObserver = OEEventsObserver()
        self.openEarsEventsObserver.delegate = self
        
        var lmGenerator: OELanguageModelGenerator = OELanguageModelGenerator()
        
        addWords()
        
        var name = "UberEmergencyModel"
       // lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        lmGenerator.generateRejectingLanguageModelFromArray(words, withFilesNamed: name, withOptionalExclusions: nil, usingVowelsOnly: false, withWeight: nil, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
    }
    
    
    func startListening() {
        try! OEPocketsphinxController.sharedInstance().setActive(true)
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
    }
    
    func stopListening() {
        OEPocketsphinxController.sharedInstance().stopListening()
    }
    
    
    
    
    func addWords() {

        words.append("NEXT")
        words.append("SEND")
        
        // Add medication names
        words.append("LIPITOR")
        words.append("NEXIUM")
        words.append("PLAVIX")
        words.append("ABILIFY")
        words.append("SEROQUEL")
        words.append("SINGULAIR")
        words.append("CRESTOR")
        words.append("ACTOS")
        words.append("HYDROCODONE")
        
        // Add allergy names
        words.append("PEANUTS")
        words.append("POLLEN")
        words.append("GRASS")
        words.append("WHEAT")
        words.append("DOGS")
        words.append("CASTS")
     
        // Add days
        words.append("SUNDAY")
        words.append("MONDAY")
        words.append("TUESDAY")
        words.append("WEDNESDAY")
        words.append("THURSDAY")
        words.append("FRIDAY")
        words.append("SATURDAY")
        
        // Add months
        words.append("JANUARY")
        words.append("FEBRUARY")
        words.append("MARCH")
        words.append("APRIL")
        words.append("MAY")
        words.append("JUNE")
        words.append("JULY")
        words.append("AUGUST")
        words.append("SEPTEMBER")
        words.append("OCTOBER")
        words.append("NOVEMBER")
        words.append("DECEMBER")
        
        // Add dates
        words.append("FIRST")
        words.append("SECOND")
        words.append("THIRD")
        words.append("FOURTH")
        words.append("FIFTH")
        words.append("SIXTH")
        words.append("SEVENTH")
        
        // Add names
        words.append("KYLE")
        words.append("BILLY")
        words.append("JOE")
        words.append("KATY")
        words.append("PAUL")
        words.append("NANCY")
        words.append("KATELYN")
    }
    

    
    func pocketsphinxFailedNoMicPermissions() {
        
        NSLog("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
        if OEPocketsphinxController.sharedInstance().isListening {
            var error = OEPocketsphinxController.sharedInstance().stopListening() // Stop listening if we are listening.
            if(error != nil) {
                NSLog("Error while stopping listening in micPermissionCheckCompleted: %@", error);
            }
        }
    }
    
    
    var heardText = ""
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        heardText = hypothesis
        print(hypothesis)
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)

    }
    
   
    
    // MARK: OEEventsObserver Delegate Methods
    func pocketsphinxDidStartListening() {
        print("Pocketsphinx is now listening.")
    }
    
    func pocketsphinxDidDetectSpeech() {
        print("Pocketsphinx has detected speech.")
    }
    
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Pocketsphinx has detected a period of silence, concluding an utterance.")
    }
    
    func pocketsphinxDidStopListening() {
        print("Pocketsphinx has stopped listening.")
    }
    
    func pocketsphinxDidSuspendRecognition() {
        print("Pocketsphinx has suspended recognition.")
    }
    
    func pocketsphinxDidResumeRecognition() {
        print("Pocketsphinx has resumed recognition.")
    }
    
    func pocketsphinxDidChangeLanguageModelToFile(newLanguageModelPathAsString: String, newDictionaryPathAsString: String) {
        print("Pocketsphinx is now using the following language model: \(newLanguageModelPathAsString) and the following dictionary: \(newDictionaryPathAsString)")
    }
    
    func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String) {
        print("Listening setup wasn't successful and returned the failure reason: \(reasonForFailure)")
    }
    
    func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String) {
        print("Listening teardown wasn't successful and returned the failure reason: \(reasonForFailure)")
    }
    
    func testRecognitionCompleted() {
        print("A test file that was submitted for recognition is now complete.")
    }
}
