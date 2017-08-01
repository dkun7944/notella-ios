//
//  Tempo.m
//  Notella
//
//  Created by Daniel Kuntz on 3/30/16.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

#import "Metronome.h"
#import "TheAmazingAudioEngine.h"
// #import "crescendo-Bridging-Header.h"

@protocol MetronomeDelegate
- (void)pulseDownbeat;
- (void)pulseUpbeat;
- (void)animateInnerCircleWithDuration:(NSTimeInterval)duration;
- (void)stopAnimatingInnerCircle;
@end

@implementation Metronome
@synthesize delegate;

- (id)init {
    self.tempo = 120.0;
    self.on = NO;
    self.beatType = 440.0;
    
    self.hasPassedFirstLaunch = NO;
    self.shouldSendUpdate = NO;
    
    self.framesUntilStart = -1;
    self.beatsSinceStart = 0;
    
    [self setupAudioController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMetronomeFromHost:) name:@"toggleMetronomeOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendUpdateOnNextBeat) name:@"sendUpdateOnNextBeat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSubdivision) name:@"currentSubdivisionChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSoundDemo:) name:@"playSoundDemo" object:nil];
    
    self.averageoffset = 0.0;
    self.numberOfRequests = 0;
    
    return self;
}

- (void)setupAudioController {
    // Create the audio controller
    self.audioController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                            inputEnabled:YES]; // don't forget to autorelease if you don't use ARC!
    
    // Start the audio controller
    NSError *error = NULL;
    BOOL result = [_audioController start:&error];
    if (!result) {
        NSLog(@"_audioController start error: %@", [error localizedDescription]);
        return;
    }
    
    self.soundOn = true;
    
    // The total frames that have passed
    self.total_frames = 0;
    
    // The number of subdivisions per note
    int subdivisions = 1;
    self.subdivisionType = subdivisions;
    
    switch (subdivisions) {
        case 1: // Quarter
            self.numberOfSubdivisions = 1;
            break;
        case 2: // Eighth
            self.numberOfSubdivisions = 2;
            break;
        case 3: // Triplet
            self.numberOfSubdivisions = 3;
            break;
        case 4: // Sixteenth
            self.numberOfSubdivisions = 4;
            break;
        case 5: // DottedQuarter
            self.numberOfSubdivisions = 1;
            break;
        case 6: // ThreeEighths
            self.numberOfSubdivisions = 3;
            break;
        case 7: // SwingEighth
            self.numberOfSubdivisions = 3;
            break;
        default:
            break;
    }
    
    self.currentSubdivision = 0;
    
    // Set the current time signature
    self.beatsPerMeasure = 4;
    self.currentBeat = 0;
    self.cumulativeCurrentBeat = 1;
    self.measureNumber = 10000;
    
    // The next frame that the beat will play on
    self.next_beat_frame = 0;
    
    // YES if we are currently sounding a beat
    self.making_beat = NO;
    self.making_subdivision = NO;
    self.making_downbeat = NO;
    
    // Oscillator
    [self resetBeatType];
    
    self.oscillatorPosition = 0; // this is outside the block since beats can span calls to the block
    self.oscillatorTime = 0;
    
    self.subOscillatorPosition = 0;
    self.subOscillatorTime = 0;
    
    self.samplesInQuarter = 16;
    
    [self setupBlockChannel];
}

- (void)setupBlockChannel {
    static UInt32 playHead;
    
    // The block that is our metronome
    self.blockChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        // How many frames pass between the start of each beat
        UInt64 frames_between_beats = 44100/(_tempo/60.) / self.numberOfSubdivisions;
        
        // For each frame, count and if we reach the frame that should start a beat, start the beat
        for (int i = 0; i < frames; i++) { // frame...by frame...
            
            if (_total_frames == 0) {
                // If total_frames is 0, unmute the block channel and set everything to zero. Doing this within the block ensures that all values are set to their initial states BEFORE the current frame is analyzed and parsed into audio. This results in the metronome starting right on time every time.
                if (self.hasPassedFirstLaunch) {
                    self.blockChannel.channelIsMuted = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setonTrue" object:nil];
                    self.on = YES;
                } else {
                    _hasPassedFirstLaunch = YES;
                }
                
                _next_beat_frame = 800;
                _next_sample_frame = 850;
                _currentSubdivision = 0;
                _currentBeat = 3;
                _cumulativeCurrentBeat = 0;
                _oscillatorPosition = 0;
                _oscillatorTime = 0;
                _subOscillatorPosition = 0;
                _subOscillatorTime = 0;
            }
            
            if (_framesUntilStart == 0) {
                _total_frames = -1;
                _framesUntilStart = -1;
            } else {
                _framesUntilStart--;
            }
            
            if (_next_sample_frame == _total_frames) {
                if (self.on) {
//                    [self.delegate takeSample];
                }
                _next_sample_frame += frames_between_beats / _samplesInQuarter;
            }
            
            if (_next_beat_frame == _total_frames + 1000) {
                if (!self.blockChannel.channelIsMuted) {
                    [self.delegate pulseDownbeat];
                }
            }
            
            // Set a flag that triggers code below to start a beat
            if (_next_beat_frame == _total_frames) {
                if (_beatsPerMeasure == 1) { // If time signature is 1/4
                    if (_currentSubdivision == 0) {
                        _making_beat = YES;
                        _making_subdivision = NO;
                        
//                        if (!self.blockChannel.channelIsMuted) {
//                            [self.delegate pulseDownbeat];
//                        }
                        
                    } else {
                        _making_beat = NO;
                        _making_subdivision = YES;
                    }
                } else { // All other time signatures
                    if (_currentSubdivision == 0) {
                        if ([self shouldMakeDownbeat]) {
                            _making_beat = YES;
                            _making_subdivision = NO;
//                            if (!self.blockChannel.channelIsMuted) {
//                                [self.delegate pulseDownbeat];
//                            }
                        } else {
                            _making_beat = NO;
                            _making_subdivision = YES;
//                            if (!self.blockChannel.channelIsMuted) {
//                                [self.delegate pulseUpbeat];
//                            }
                        }
                        
                        _currentBeat ++;
                        _cumulativeCurrentBeat ++;
                    } else {
                        if (!(_subdivisionType == 7 && _currentSubdivision == 1)) { // Mute the second eighth when swing eighths is the subdivision type
                            _making_subdivision = YES;
                            _making_beat = NO;
                        } else {
                            _making_beat = NO;
                            _making_subdivision = NO;
                        }
                    }
                }
                
                _oscillatorPosition = 0; // Reset the oscillator position
                _next_beat_frame += frames_between_beats;
                _currentSubdivision ++;
                
                if (_currentSubdivision >= _numberOfSubdivisions) {
                    _currentSubdivision = 0;
                }
                
                if (_currentBeat >= _beatsPerMeasure) {
                    _currentBeat = 0;
                    _measureNumber++;
                }
                
                if (_measureNumber == 2) {
                    _measureNumber = 10000;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopPlayingSoundDemo" object:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self resetBeatType];
                        [self resetTimeSignature];
                    });
                }
                
                playHead = 0;
            }
            
            if (!_soundOn) {
                _making_downbeat = NO;
                _making_beat = NO;
                _making_subdivision = NO;
            }
            
            if (_making_subdivision && _soundOn) {
                if (_beatType == 0) {
                    for ( int j=0; j < audio->mNumberBuffers; j++ ) {
                        if (playHead < _upbeatLengthInFrames ) {
                            ((SInt16 *)audio->mBuffers[j].mData)[i] = ((SInt16 *)_upbeatBufferList->mBuffers[0].mData)[playHead+1];
                        } else {
                            _making_beat = NO;
                            _making_subdivision = NO;
                            ((SInt16 *)audio->mBuffers[j].mData)[i] = 0;
                        }
                    }
                } else {
                    [self subdivisionWriteBufferDataForCurrentIndex:i audioBufferList:audio];
                }
            }
            
            if (_making_beat && _soundOn) {
                if (_beatType == 0) {
                    for ( int j=0; j < audio->mNumberBuffers; j++ ) {
                        if (playHead < _downbeatLengthInFrames ) {
                            ((SInt16 *)audio->mBuffers[j].mData)[i] = ((SInt16 *)_downbeatBufferList->mBuffers[0].mData)[playHead+1];
                        } else {
                            _making_beat = NO;
                            ((SInt16 *)audio->mBuffers[j].mData)[i] = 0;
                        }
                    }
                } else {
                    [self downbeatWriteBufferDataForCurrentIndex:i audioBufferList:audio];
                }
            }
            
            if (_making_downbeat && _soundOn) {
                if (_beatType == 0) {
                    for ( int j=0; j < audio->mNumberBuffers; j++ ) {
                        if (playHead < _downbeatLengthInFrames ) {
                            ((SInt16 *)audio->mBuffers[j].mData)[i] = ((SInt16 *)_downbeatBufferList->mBuffers[0].mData)[playHead+1];
                        } else {
                            _making_downbeat = NO;
                            ((SInt16 *)audio->mBuffers[j].mData)[i] = 0;
                        }
                    }
                } else {
                    [self downbeatWriteBufferDataForCurrentIndex:i audioBufferList:audio];
                }
            }
            
            _total_frames++;
            playHead++;
        }
    }];
    
    self.blockChannel.channelIsMuted = YES;
    
    [_audioController addChannels:[NSArray arrayWithObject:_blockChannel]];
}

- (AudioBufferList *)bufferListForFileName:(NSString *)fileName {
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc]
                                             initWithFileURL:[[NSBundle mainBundle] URLForResource:fileName withExtension:@"wav"]
                                             targetAudioDescription:_audioController.audioDescription];
    [operation start];
    if (operation.error) {
        NSLog(@"load error: %@", operation.error);
        return nil;
    }

    return operation.bufferList;
}

- (UInt32)lengthInFramesForFileName:(NSString *)fileName {
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc]
                                             initWithFileURL:[[NSBundle mainBundle] URLForResource:fileName withExtension:@"wav"]
                                             targetAudioDescription:_audioController.audioDescription];
    [operation start];
    if (operation.error) {
        NSLog(@"load error: %@", operation.error);
        return 0;
    }
    
    return operation.lengthInFrames;
}

- (BOOL)shouldMakeDownbeat {
    NSString *timeSignature = @"4/4";
    BOOL shouldMakeDownbeat = true;
    
    if ([timeSignature isEqualToString:@"1/4"] || [timeSignature isEqualToString:@"2/4"] || [timeSignature isEqualToString:@"3/4"] || [timeSignature isEqualToString:@"4/4"] || [timeSignature isEqualToString:@"3/8"] || [timeSignature isEqualToString:@"6/8"] || [timeSignature isEqualToString:@"9/8"] || [timeSignature isEqualToString:@"12/8"]) {
        if (_currentBeat != 3) {
            shouldMakeDownbeat = false;
        }
    } else if ([timeSignature isEqualToString:@"2+2+1"]) {
        if (_currentBeat != 0 && _currentBeat != 2 && _currentBeat != 4) {
            shouldMakeDownbeat = false;
        }
    } else if ([timeSignature isEqualToString:@"3+2"]) {
        if (_currentBeat != 0 && _currentBeat != 3) {
            shouldMakeDownbeat = false;
        }
    } else if ([timeSignature isEqualToString:@"2+3"]) {
        if (_currentBeat != 0 && _currentBeat != 2) {
            shouldMakeDownbeat = false;
        }
    } else if ([timeSignature isEqualToString:@"2+2+3"]) {
        if (_currentBeat != 0 && _currentBeat != 2 && _currentBeat != 4) {
            shouldMakeDownbeat = false;
        }
    } else if ([timeSignature isEqualToString:@"4+3"]) {
        if (_currentBeat != 0 && _currentBeat != 4) {
            shouldMakeDownbeat = false;
        }
    } else if ([timeSignature isEqualToString:@"3+4"]) {
        if (_currentBeat != 0 && _currentBeat != 3) {
            shouldMakeDownbeat = false;
        }
    }
    
    return shouldMakeDownbeat;
}

- (void)downbeatWriteBufferDataForCurrentIndex:(int)i audioBufferList:(AudioBufferList *)audio {
    _oscillatorPosition += self.oscillatorRate;
    _oscillatorTime += 1;
    
    if (_oscillatorPosition > 1.0) {
        _oscillatorPosition -= 2.0;
        
        if (_oscillatorTime > 300) {
            _making_downbeat = NO;
            _making_beat = NO;
            _oscillatorTime = 0;
        }
    }
    
    float x = _oscillatorPosition;
    x *= x; x -= 1.0; x *= x;       // x now in the range 0...1
    x *= INT16_MAX;
    x -= INT16_MAX / 2;
    
    ((SInt16*)audio->mBuffers[0].mData)[i] = x;
    ((SInt16*)audio->mBuffers[1].mData)[i] = x;
}

- (void)subdivisionWriteBufferDataForCurrentIndex:(int)i audioBufferList:(AudioBufferList *)audio {
    _subOscillatorPosition += self.subOscillatorRate;
    _subOscillatorTime += 1;
    
    if (_subOscillatorPosition > 1.0) {
        _subOscillatorPosition -= 2.0;
        
        if (_subOscillatorTime > 300) {
            _making_subdivision = NO;
            _making_beat = NO;
            _subOscillatorTime = 0;
        }
    }
    
    float x = _subOscillatorPosition;
    x *= x; x -= 1.0; x *= x;       // x now in the range 0...1
    x *= INT16_MAX;
    x -= INT16_MAX / 2;
    
    ((SInt16*)audio->mBuffers[0].mData)[i] = x;
    ((SInt16*)audio->mBuffers[1].mData)[i] = x;
}

- (void)resetBeatType {
    self.beatType = 4698.0;
    self.oscillatorRate = self.beatType/44100.0;
    self.subBeatType = 3520.0;
    self.subOscillatorRate = self.subBeatType/44110.0;
}

- (void)resetSubdivision {
    // The number of subdivisions per note
    int subdivisions = 1;
    self.subdivisionType = subdivisions;
    
    switch (subdivisions) {
        case 1: // Quarter
            self.numberOfSubdivisions = 1;
            break;
        case 2: // Eighth
            self.numberOfSubdivisions = 2;
            break;
        case 3: // Triplet
            self.numberOfSubdivisions = 3;
            break;
        case 4: // Sixteenth
            self.numberOfSubdivisions = 4;
            break;
        case 5: // DottedQuarter
            self.numberOfSubdivisions = 1;
            break;
        case 6: // ThreeEighths
            self.numberOfSubdivisions = 3;
            break;
        case 7: // SwingEighth
            self.numberOfSubdivisions = 3;
            break;
        default:
            break;
    }
    
    self.currentSubdivision = 0;
}

- (void)resetTimeSignature {
    self.beatsPerMeasure = 4;
    self.currentBeat = 0;
}

- (void)playSingleBeat {
    float storeTempo = _tempo;
    _tempo = 30.0;
    
    // By setting the total_frames to zero, the block channel is triggered to unmute itself and reset all other necessary variables.
    self.total_frames = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.blockChannel.channelIsMuted = YES;
        [self stopTapping];
        _tempo = storeTempo;
    });
}

- (void)startTapping {
    if (![_audioController running]) {
        NSError *error = NULL;
        BOOL result = [_audioController start:&error];
        if (!result) {
            NSLog(@"_audioController start error: %@", [error localizedDescription]);
            return;
        }
    }

    self.total_frames = 0;
    self.on = YES;
}

- (void)stopTapping {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setonFalse" object:nil];

    self.blockChannel.channelIsMuted = YES;
    _framesUntilStart = -1;
    
    self.on = NO;
//    [self resetBeatType];
}

- (void)startMetronomeFromHost:(NSNotification *)notification {
    NSLog(@"Start metronome from host");
    
    if (![_audioController running]) {
        NSError *error = NULL;
        BOOL result = [_audioController start:&error];
        if (!result) {
            NSLog(@"_audioController start error: %@", [error localizedDescription]);
            return;
        }
    }
    
    NSDate *startDate = (NSDate *)(notification.userInfo[@"start_date"]);
    
    if ([startDate timeIntervalSinceNow] <= 1.0) { // Start date is in the past
        NSLog(@"Start date in past");
        
        NSTimeInterval timeUntilStart = fabs([startDate timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval:self.averageoffset]]);
        NSLog(@"%f", timeUntilStart);
        UInt64 frames = (int)(timeUntilStart * 44100);
        _framesUntilStart = frames;
        
        NSLog(@"%f", timeUntilStart);
        
    } else { // Start date is in the future
        NSLog(@"Start date in future");
        
        NSTimeInterval timeUntilStart = [startDate timeIntervalSinceDate:[[NSDate date] dateByAddingTimeInterval:self.averageoffset]];
        UInt64 frames = (int)(timeUntilStart * 44100);
        
        _framesUntilStart = frames;
        NSLog(@"%llu", frames);
    }
}

- (void)sendUpdateOnNextBeat {
    NSLog(@"Set should send update");
    self.shouldSendUpdate = YES;
}

@end
