//
//  ViewController.swift
//  AudioPlayer
//
//  Created by PaditechDev1 on 9/15/16.
//  Copyright © 2016 PaditechDev1. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, XQAudioPlayerDelegate {

    let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initComponent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Init
    func initComponent() {
        let url = "http://www.stephaniequinn.com/Music/Allegro%20from%20Duet%20in%20C%20Major.mp3"
        let audioPlayer = XQAudioPlayer.init(frame: CGRect(x: 0, y: 70, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 0.12), urlString: url)
        self.view.addSubview(audioPlayer)
        
        // Change progress color
        audioPlayer.progressColor = UIColor.blueColor()
        
        // Change background color
        audioPlayer.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        // Change background progress color
        audioPlayer.progressBackgroundColor = UIColor.grayColor()
        
        // Change title time label color
        audioPlayer.timeLabelColor = UIColor.blackColor()
        
        // Change height of progress
        audioPlayer.progressHeight = 6
        
        // Change button play image
        audioPlayer.playingImage = UIImage(named:"icon_playing")
        audioPlayer.pauseImage = UIImage(named:"icon_pause")
        
        // Setting delegate
        audioPlayer.delegate = self
        
    }
    
    /* Player did updated duration time
     * You can get duration time of audio in here
     */
    func playerDidUpdateDurationTime(player: XQAudioPlayer, durationTime: CMTime) {
        
    }
    
    /* Player did change time playing
     * You can get current time play of audio in here
     */
    func playerDidUpdateCurrentTimePlaying(player: XQAudioPlayer, currentTime: CMTime) {
        
    }
    
    // Player begin start
    func playerDidStart(player: XQAudioPlayer) {
        
    }
    
    // Player stoped
    func playerDidStoped(player: XQAudioPlayer) {
        
    }
    
    // Player did finish playing
    func playerDidFinishPlaying(player: XQAudioPlayer) {
        
    }

}



