//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by SSA on 27/07/17.
//  Copyright © 2017 SSA. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {

    @IBOutlet weak var labelRecording: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder : AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.imageView?.contentMode = .scaleAspectFit
        
        configureUI( false )
    }
    
    private func configureUI(_ recording : Bool) {
        labelRecording.text = recording ? "Recording..." : "Tap to record"
        stopRecordingButton.isEnabled = recording
        recordButton.isEnabled = !recording
    }

    @IBAction func recordAudio(_ sender: Any) {
        startAudioRecorder()
        configureUI( true )
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        configureUI( false )
        stopAudioRecorder()
    }
    
    private func startAudioRecorder() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        print(filePath!)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    private func stopAudioRecorder() {
        audioRecorder.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            playSoundsVC.recordedAudioURL = sender as! URL
        }
    }
    
}

extension RecordSoundsViewController : AVAudioRecorderDelegate {
 
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            let alert = UIAlertController(title: "Audio Recorder Error", message: "Something went wrong with the audio recorder", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        self.performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
    }
    
}

