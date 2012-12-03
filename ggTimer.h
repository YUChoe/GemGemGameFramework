//
//  ggTimer.h
//  gemgem
//
//  Created by Yong-uk Choe on 12. 12. 3..
//
//

#import <Foundation/Foundation.h>
#import "ggConfig.h"


typedef enum {
  ggTimerSTAT_STOPPED, // just initized, finished, ... etc
  ggTimerSTAT_RUNNING,
  ggTimerSTAT_PAUSED
} ggTimerStatus;

@interface ggTimer : NSObject
{
  ggTimerStatus status;
  
  CCSprite *bar1;
  CCSprite *bar2;
  CCSprite *bar3;
  CGPoint timerPosition;
  
  NSTimer *Timer;
  float timer_interval;
  
  int currentValue;
  int warningPoint;
  int dangerPoint;
}

-(id)initWithCCLayer:(CCLayer *)cclayer;

-(void) setState:(ggTimerStatus)newStatus;
-(ggTimerStatus) getState;

-(int) getCurrentValue;

-(void) start;
-(void) pause;
-(void) resume;
@end
