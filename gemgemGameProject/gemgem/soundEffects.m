//
//  soundEffects.m
//  gemgem
//
//  Created by Yong-uk Choe on 12/12/21.
//
//

#import "soundEffects.h"

@implementation soundEffects


-(id) init {
  if( (self=[super init])) {
    effObjs = [[NSMutableArray alloc] init];
    isMute = NO;
    
    sae = [SimpleAudioEngine sharedEngine];
    if (sae != nil) {
      if (sae.willPlayBackgroundMusic) {
        sae.backgroundMusicVolume = 0.5f;
      }
    } // of preloading

  }
  return self;
}
-(void) setMute:(BOOL)mute {
  isMute = mute;
}
-(BOOL) isMute {
  return isMute;
}

-(void) setSoundEffectWithFilename:(NSString *)filename {
  if (sae != nil) {
    [sae preloadBackgroundMusic:filename];//@"bombexplosion.wav"];
    [effObjs addObject:filename];
    NSLog(@"sound effects[%d]:%@", [effObjs count]-1, filename);
  } else {
    NSLog(@"called preloadBackgroundMusic withoutInit");
  }
}
-(void) playSoundEffectByIndex:(int)index {
  if (isMute == NO) {
    NSString *filename = [effObjs objectAtIndex:index];
    NSLog(@"playSoundEffectByIndex[%d]:%@", index, filename);
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:filename loop:NO];
  }
}

@end
