//
//  XQAudioPlayer.swift
//  AudioPlayer
//
//  Created by PaditechDev1 on 9/15/16.
//  Copyright © 2016 PaditechDev1. All rights reserved.
//

import UIKit
import AVFoundation

enum AVPlayerState {
    case Playing
    case Paused
    case Reserved
    case Unknown
}

@objc protocol XQAudioPlayerDelegate: class {
    
    /* Player did updated duration time
     * You can get duration time of audio in here
     */
    func playerDidUpdateDurationTime(player: XQAudioPlayer, durationTime: CMTime)
    
    /* Player did change time playing
     * You can get current time play of audio in here
     */
    func playerDidUpdateCurrentTimePlaying(player: XQAudioPlayer, currentTime: CMTime)
    
    // Player begin start
    func playerDidStart(player: XQAudioPlayer)
    
    // Player stoped
    func playerDidStoped(player: XQAudioPlayer)
    
    // Player did finish playing
    func playerDidFinishPlaying(player: XQAudioPlayer)
    
}

class XQAudioPlayer: UIView {
    
    // MARK: - Variable
    var state: AVPlayerState = .Unknown
    var audioPlayer = AVPlayer()
    var currentAudioPath:NSURL!
    var delegate : XQAudioPlayerDelegate!
    
    var progressView: UIView!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var playerProgressSlider : XQSlider!
    @IBOutlet var totalLengthOfAudioLabel : UILabel!
    @IBOutlet var timeLabel : UILabel!
    @IBOutlet var playerView : UIView!
    
    var progressWidth: CGFloat!
    var progressHeight: CGFloat {
        
        get {
            return self.playerProgressSlider != nil ? self.playerProgressSlider.bounds.size.height : 0.0
        }
        
        set (newHeight){
            self.playerProgressSlider.trackHeight = newHeight
        }
    }
    
    var progressColor: UIColor! {
        get {
            return self.playerProgressSlider.minimumTrackTintColor
        }
        
        set (newColor) {
            self.playerProgressSlider.minimumTrackTintColor = newColor
        }
    }
    
    var progressBackgroundColor: UIColor! {
        get {
            return self.playerProgressSlider.maximumTrackTintColor
        }
        
        set (newColor) {
            self.playerProgressSlider.maximumTrackTintColor = newColor
        }
    }
    
    var timeLabelColor: UIColor! {
        get {
            return self.timeLabel.textColor
        }
        
        set (newColor) {
            self.timeLabel.textColor = newColor
        }
    }
    
    var thumbColor: UIColor {
        
        get {
            return self.playerProgressSlider.thumbTintColor!
        }
        
        set (newColor) {
            self.playerProgressSlider.thumbTintColor = newColor
        }
    }
    
    var playingImage: UIImage! {
        
        get {
            return  UIImage(named: "icon_playing")
        }
        
        set (newImage) {
            
        }
    }
    
    var pauseImage: UIImage! {
        get {
            return UIImage(named: "icon_pause")
        }
        
        set (newImage) {
            
        }
    }
    var timer = Timer()
    let SCREEN_WIDTH = UIScreen.main.bounds.size.width;
    init (frame : CGRect, urlString: String) {
        super.init(frame : frame)
        config(urlString: urlString)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    //MARK: Init
    func config(urlString: String) {
        
        // Init playerView
        let playerHeight = self.frame.size.height;
        let playerWidth = self.frame.size.width;
        self.playerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: playerHeight))
        self.playerView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = true
        self.addSubview(self.playerView)
        
        // Init button play
        self.playButton = UIButton(frame: CGRect(x: 0, y: 0, width: playerWidth/8.0, height: playerHeight))
        self.playButton.backgroundColor = UIColor.clear
        self.playButton.layer.masksToBounds = true
        self.playButton.titleLabel?.textAlignment = NSTextAlignment.center
        playButton.setImage(self.pauseImage, for: .normal)
        self.playerView.addSubview(self.playButton)
        self.playButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        //Init sliderbar Button
        let slideView = UIView(frame: CGRect(x: playerWidth/8.0, y: 0, width: playerWidth*0.75, height: playerHeight))
        slideView.backgroundColor = UIColor.clear
        self.playerView.addSubview(slideView)
        
        self.playerProgressSlider = XQSlider(frame: CGRect(x: 0, y: 0, width: slideView.frame.size.width, height: playerHeight))
        self.progressWidth = slideView.frame.size.width
        self.playerProgressSlider.value = 0.0
        self.playerProgressSlider.tintColor = UIColor.green
        self.playerProgressSlider.backgroundColor = UIColor.clear
        self.playerProgressSlider.addTarget(self, action: #selector(self.sliderValueDidChange), for: .valueChanged)
        self.playerProgressSlider.setThumbImage(UIImage(), for: .normal)
        slideView.addSubview(self.playerProgressSlider)
        
//        self.progressWidth = slideView.frame.size.width  - 10
//        let progressBacground = UIView(frame: CGRect(x: 5,y: (playerHeight - 5)/2.0 ,width: self.progressWidth, height: 5))
//        slideView.addSubview(progressBacground)
//        
//        progressBacground.backgroundColor = UIColor.grayColor()
//        
//        self.progressView = UIView(frame: CGRect(x: 0,y: 0,width: self.progressWidth, height: 5))
//        self.progressView.backgroundColor = UIColor.redColor()
//        progressBacground.addSubview(self.progressView)
        
        // Init title label time
        self.timeLabel = UILabel(frame: CGRect(x: 7/8.0*playerWidth, y: 0, width: playerWidth * 1/8.0, height: playerHeight))
        self.timeLabel.textColor = UIColor.lightGray
        self.timeLabel.textAlignment = .center
        self.timeLabel.text = "--:--"
        self.timeLabel.font = UIFont.systemFont(ofSize: 12)
        self.playerView.addSubview(self.timeLabel)
        
        // Config url
        self.configWithAudioURLString(url: urlString)
    }
    
    func configWithAudioURLString(url: String) {
        let playerItem = AVPlayerItem( url: NSURL( string:url )! as URL)
        self.audioPlayer = AVPlayer(playerItem:playerItem)
        self.audioPlayer.rate = 1.0;
        self.audioPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        self.audioPlayer.pause()
    }
    
    // MARK: - Button action
    @IBAction func buttonAction(sender : AnyObject) {
        if (self.audioPlayer.currentItem != nil) {
            if state == .Playing {
                self.audioPlayer.pause()
            } else {
                
                if(self.audioPlayer.currentItem?.currentTime().durationText == self.audioPlayer.currentItem?.asset.duration.durationText) {
                    self.audioPlayer.seek(to: CMTime.zero)
                }
                
                self.audioPlayer.play()
            }
        }
    }
    
    @objc func sliderValueDidChange(sender:UISlider!)
    {
        let seekTime = CMTimeMakeWithSeconds(Double(sender.value) * CMTimeGetSeconds(self.audioPlayer.currentItem!.asset.duration), preferredTimescale: 1);
        self.audioPlayer.seek(to: seekTime);
    }
    
    //MARK: Set progress value
    func setProgress(value: CGFloat) {
        
        if value < 0.0 || value > 1.0 {
            return
        } else {
            var frame = self.progressView.frame
            frame.size.width = value * self.progressWidth
            self.progressView.frame = frame
        }
    }

    
    override func observeValue(forKeyPath keyPath: String?,
          of object: Any?,
     change: [NSKeyValueChangeKey : Any]?,
    context: UnsafeMutableRawPointer?)
{
        
        if keyPath == "rate" {
            
            if let rate = change?[NSKeyValueChangeKey.newKey] as? Float {
                
                if rate == 0.0 {
                    print("playback stopped")
                    
                    // Call delegate
                    if self.delegate != nil {
                        self.delegate.playerDidStoped(player: self)
                    }
                    
                    // Cancel timer update laber title
                    self.cancelTimer()
                    state = .Paused
                    self.playButton.setImage(self.pauseImage, for: .normal)
                }
                
                if rate == 1.0 {
                    print("normal playback")
                    
                    // Call delegate
                    if self.delegate != nil {
                        self.delegate.playerDidStart(player: self)
                        self.delegate.playerDidUpdateDurationTime(player: self, durationTime: (self.audioPlayer.currentItem?.asset.duration)!)
                    }
                    
                    
                    // Begin update label time
                    self.startTimer()
                    state = .Playing
                    self.playButton.setImage(self.playingImage, for: .normal)
                }
                
                if rate == -1.0 {
                    print("reverse playback")
                    state = .Reserved
                    self.playButton.setImage(self.pauseImage, for: .normal)
                }
            }
        }
    }
    
    // MARK: - Timer update status of player
    func startTimer() {
        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    // stop timer
    func cancelTimer() {
        timer.invalidate()
    }
    
    @objc func timerAction() {
        self.timeLabel.text = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.audioPlayer.currentItem!.asset.duration) - CMTimeGetSeconds(self.audioPlayer.currentTime()), preferredTimescale: 1).durationText
        let rate = Float(CMTimeGetSeconds(self.audioPlayer.currentTime())/CMTimeGetSeconds(self.audioPlayer.currentItem!.asset.duration))
        
        self.playerProgressSlider.setValue(rate, animated: false)
        
        // Call delegate
        if(CMTimeGetSeconds(self.audioPlayer.currentItem!.asset.duration) - CMTimeGetSeconds(self.audioPlayer.currentTime()) < 1 && self.delegate != nil) {
            self.delegate.playerDidFinishPlaying(player: self)
        }
        
        if self.delegate != nil {
            self.delegate.playerDidUpdateCurrentTimePlaying(player: self, currentTime: (self.audioPlayer.currentItem?.currentTime())!)
        }
    }
    
}

//MARK: CMTime extension
extension CMTime {
    var durationText:String {
//        let totalSeconds = CMTimeGetSeconds(self)
//        let hours: Int = Int(totalSeconds / 3600)
//        let minutes:Int = Int(totalSeconds % 3600 / 60)
//        let seconds:Int = Int(totalSeconds % 60)
        let totalSeconds = CMTimeGetSeconds(self)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

class XQSlider: UISlider {
    var yCenter: CGFloat!
    var trackHeight: CGFloat = 4
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: center.y - trackHeight/2.0 , width: bounds.size.width, height: max(trackHeight, 4))
    }
}
