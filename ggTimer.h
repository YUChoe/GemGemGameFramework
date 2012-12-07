//
//  ggTimer.h
//  gemgem
//
//  Created by Yong-uk Choe on 12. 12. 3..
//
//

#import <Foundation/Foundation.h>
#import "ggConfig.h"

#define GG_NOTIFICATION_TIMEOUT   @"ggEVENT_Timeout"

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
  int barWidth;
  
  NSTimer *Timer;
  float timer_interval;
  
  int startValue;
  int currentValue;
  int warningPoint;
  int dangerPoint;
  
  CCLayer *thisLayer;
}

-(id) initWithCCLayer:(CCLayer *)cclayer at:(CGPoint)position startSize:(int)timerBarWidth;

-(void) setState:(ggTimerStatus)newStatus;
-(ggTimerStatus) getState;

-(int) getCurrentValue;
-(void) setBonusTime:(float)bonustime;

-(void) start;
-(void) pause;
-(void) resume;
@end
