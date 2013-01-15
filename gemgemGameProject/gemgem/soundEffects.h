//
//  soundEffects.h
//  gemgem
//
//  Created by Yong-uk Choe on 12/12/21.
//
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"

@interface soundEffects : NSObject
{
  NSMutableArray *effObjs;
  SimpleAudioEngine *sae;
  BOOL isNoBGMusic;
  BOOL isMute;
}

-(id) init;

-(void) setMute:(BOOL)mute;
-(BOOL) isMute;
-(void) setNoBGMusic:(BOOL)noBGMusic;
-(BOOL) isNoBGMusic;

-(void) setSoundEffectWithFilename:(NSString *)filename;
-(void) playSoundEffectByIndex:(int)index;

@end
