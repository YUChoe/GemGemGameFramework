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
  BOOL isMute;
}

-(id) init;
-(void) setMute:(BOOL)mute;

-(void) setSoundEffectWithFilename:(NSString *)filename;
-(void) playSoundEffectByIndex:(int)index;

@end
