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

    sae = [SimpleAudioEngine sharedEngine];
    if (sae != nil) {
      [sae preloadBackgroundMusic:@"bombexplosion.wav"];
      
      if (sae.willPlayBackgroundMusic) {
        sae.backgroundMusicVolume = 0.5f;
      }
    } // of preloading

  }
  return self;
}
-(void) setMute:(BOOL)mute {
}

-(void) setSoundEffectWithFilename:(NSString *)filename {
  
}
-(void) playSoundEffectByIndex:(int)index {
  
}

@end
