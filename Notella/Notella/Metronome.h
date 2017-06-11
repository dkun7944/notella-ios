//
//  Tempo.h
//  Notella
//
//  Created by Daniel Kuntz on 3/30/16.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"

@class AEAudioController;
@class AEBlockChannel;

@interface Metronome : NSObject

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEBlockChannel *blockChannel;
@property (nonatomic, assign) int tempo;
@property (nonatomic, assign) UInt64 numberOfSubdivisions;
@property (nonatomic, assign) UInt64 subdivisionType;
@property (nonatomic, assign) UInt64 currentSubdivision;

@property (nonatomic, assign) UInt32 cumulativeCurrentBeat;
@property (nonatomic, assign) UInt16 samplesInQuarter;
@property (nonatomic, assign) UInt64 next_sample_frame;

@property (nonatomic, assign) UInt64 beatsPerMeasure;
@property (nonatomic, assign) UInt64 currentBeat;

@property (nonatomic, assign) float beatType;
@property (nonatomic, assign) float subBeatType;
@property (nonatomic, assign) float oscillatorRate;
@property (nonatomic, assign) float subOscillatorRate;

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL on;

@property (nonatomic, assign) UInt64 total_frames;

@property (nonatomic, assign) UInt64 next_beat_frame;
@property (nonatomic, assign) float oscillatorPosition;
@property (nonatomic, assign) float oscillatorTime;

@property (nonatomic, assign) float subOscillatorPosition;
@property (nonatomic, assign) float subOscillatorTime;

@property (nonatomic, assign) BOOL making_beat;
@property (nonatomic, assign) BOOL making_subdivision;
@property (nonatomic, assign) BOOL making_downbeat;
@property (nonatomic, assign) BOOL soundOn;

@property (nonatomic, assign) BOOL hasPassedFirstLaunch;
@property (nonatomic, assign) UInt64 framesUntilStart;
@property (nonatomic, assign) UInt64 beatsSinceStart;
@property (nonatomic, assign) NSDate *startDate;

@property (nonatomic, assign) BOOL shouldSendUpdate;

@property (nonatomic, assign) double averageoffset;
@property (nonatomic, assign) int numberOfRequests;
@property (nonatomic, strong) NSTimer *noResponseTimer;

@property (nonatomic, assign) AudioBufferList *downbeatBufferList;
@property (nonatomic, assign) UInt32 downbeatLengthInFrames;
@property (nonatomic, assign) AudioBufferList *upbeatBufferList;
@property (nonatomic, assign) UInt32 upbeatLengthInFrames;

@property (nonatomic, assign) UInt32 measureNumber;

- (void)startTapping;
- (void)stopTapping;
- (void)resetBeatType;
- (void)resetSubdivision;
- (void)resetTimeSignature;
- (void)playSingleBeat;

@end
