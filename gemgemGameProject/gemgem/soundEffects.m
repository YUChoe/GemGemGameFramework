//
//  soundEffects.m
//  gemgem
//
//  Created by Yong-uk Choe on 12/12/21.
//
//

#import "soundEffects.h"
#import "optionsLayer.h"

@implementation soundEffects


-(id) init {
  if( (self=[super init])) {
    effObjs = [[NSMutableArray alloc] init];
    isMute = NO;
    [self updateByConfig]; // isMute, isNoBGMusic, etc
    
    sae = [SimpleAudioEngine sharedEngine];
    
    [[CDAudioManager sharedManager] setMode: kAMM_FxOnly];
    
    if (sae != nil) {
      if (sae.willPlayBackgroundMusic) {
        sae.backgroundMusicVolume = 0.5f;
        sae.effectsVolume = 0.5f;
      }
    }

  }
  return self;
}

-(void) updateByConfig {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  //CCLOG(@"Documents path:%@",documentsDirectory);
  
  NSString *plistPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@.plist", CONFIG_PLIST_FILENAME]];
  NSDictionary *confDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
  //CCLOG(@"confDict:%@", confDict);
  
  [self setMute: ![[confDict objectForKey:@"isEffectSoundON"] boolValue]];
  [self setNoBGMusic: ![[confDict objectForKey:@"isBackgroundMusicON"] boolValue]];
}

-(void) setMute:(BOOL)mute {
  isMute = mute;
}
-(BOOL) isMute {
  return isMute;
}

-(void) setNoBGMusic:(BOOL)noBGMusic {
  isNoBGMusic = noBGMusic;
}
-(BOOL) isNoBGMusic {
  return isNoBGMusic;
}

-(void) setSoundEffectWithFilename:(NSString *)filename {
  if (sae != nil) {
    //[sae preloadBackgroundMusic:filename];//@"bombexplosion.wav"];
    [sae preloadEffect:filename];
    [effObjs addObject:filename];
    NSLog(@"sound effects[%d]:%@", [effObjs count]-1, filename);
  } else {
    NSLog(@"called preloadBackgroundMusic withoutInit");
  }
}
-(void) playSoundEffectByIndex:(int)index {
  if (isMute == NO) {
    NSString *filename = [effObjs objectAtIndex:index];
    //NSLog(@"playSoundEffectByIndex[%d]:%@", index, filename);
    //[sae playBackgroundMusic:filename loop:NO];
    [sae playEffect:filename];
  }
}

@end
