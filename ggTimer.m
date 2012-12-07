//
//  ggTimer.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 12. 3..
//
//

#import "ggTimer.h"

@implementation ggTimer

-(id) initWithCCLayer:(CCLayer *)cclayer at:(CGPoint)position startSize:(int)timerBarWidth {
  if ( self = [super init] ) {
    thisLayer = cclayer;
    timerPosition = position;
    barWidth = timerBarWidth;
    
    // default setting
    startValue = 60; // = 100%
    warningPoint = 30; // = 50%
    dangerPoint = 15;  // = 25%
    
    timer_interval = 1.0f; // 1 second

    [self __initSprites];
    
    status = ggTimerSTAT_STOPPED;
  }
  return self;
}

-(void) timerTick:(NSTimer *)sender {
  if (status != ggTimerSTAT_STOPPED) {
    currentValue = currentValue - 1;
    CCLOG(@"time:%d", currentValue);
    
    // animation
    if (currentValue > warningPoint) {
      // green
      bar1.visible = YES;
      bar2.visible = NO;
      bar3.visible = NO;
      [bar1 runAction:[CCScaleTo actionWithDuration:(timer_interval / 2)
                                             scaleX:(barWidth / bar1.contentSize.width)*currentValue / startValue
                                             scaleY:(10/bar1.contentSize.height) ]];
    } else if (currentValue < warningPoint && currentValue > dangerPoint) {
      // yellow
      bar1.visible = NO;
      bar2.visible = YES;
      bar3.visible = NO;
      [bar2 runAction:[CCScaleTo actionWithDuration:(timer_interval/2)
                                             scaleX:(barWidth / bar2.contentSize.width)*currentValue / startValue
                                             scaleY:(10/bar2.contentSize.height) ]];
    } else if (currentValue < dangerPoint && currentValue > 0) {
      // red
      bar1.visible = NO;
      bar2.visible = NO;
      bar3.visible = YES;
      [bar3 runAction:[CCScaleTo actionWithDuration:(timer_interval/2)
                                             scaleX:(barWidth / bar3.contentSize.width)*currentValue / startValue
                                             scaleY:(10/bar3.contentSize.height) ]];
    } else if (currentValue <= 0) {
      [Timer invalidate]; // stop timer
      // send notification TODO
      [[NSNotificationCenter defaultCenter] postNotificationName:GG_NOTIFICATION_TIMEOUT object:self];
    }
  } else {
    CCLOG(@"tick but STOPPED - continue:%d", currentValue);
  }
}

-(void) setBonusTime:(float)bonustime {
  // + bonustime
  currentValue = currentValue + bonustime;
  // get current visible bar
  // animation
  
}

-(void) __initSprites {
  currentValue = startValue;
  
  bar1 = [CCSprite spriteWithFile:@"timer_bar_green.png"];
  bar2 = [CCSprite spriteWithFile:@"timer_bar_yellow.png"];
  bar3 = [CCSprite spriteWithFile:@"timer_bar_red.png"];
  
  bar1.position = timerPosition;
  bar2.position = timerPosition;
  bar3.position = timerPosition;
  
  // green bar init
  bar1.anchorPoint = ccp(0, 0.5f); // 좌하(0, 0), 우상(1, 1)
  bar1.scaleX = barWidth / bar1.contentSize.width; // screen_size.width
  bar1.scaleY = 10 / bar1.contentSize.height; // 30px 고정 불변
  CCLOG(@"init scaleX rate:%f", barWidth / bar1.contentSize.width);
  
  // yellow bar init
  bar2.anchorPoint = ccp(0, 0.5f); // 좌하(0, 0), 우상(1, 1)
  bar2.scaleX = (barWidth / bar2.contentSize.width) * warningPoint / startValue; // screen_size.width 의 50%(ratio:0.5) 에서 시작
  bar2.scaleY = 10 / bar2.contentSize.height;  // 30px 불변

  // red bar init
  bar3.anchorPoint = ccp(0, 0.5f); // 좌하(0, 0), 우상(1, 1)
  bar3.scaleX = (barWidth / bar2.contentSize.width) * dangerPoint / startValue; // screen_size.width 의 25% 에서 시작
  bar3.scaleY = 10 / bar3.contentSize.height; // 30px 불변

  bar1.visible = YES;
  bar2.visible = NO;
  bar3.visible = NO;

  [thisLayer addChild:bar1 z:33];
  [thisLayer addChild:bar2 z:32];
  [thisLayer addChild:bar3 z:31];
  CCLOG(@"timer sprite init complete *");
  CCLOG(@"bar1:(%.f,%.f) length:%.f", bar1.boundingBox.origin.x, bar1.boundingBox.origin.y, bar1.contentSize.width);
}

-(void) setState:(ggTimerStatus)newStatus {
  status = newStatus;
}

-(ggTimerStatus) getState {
  return status;
}

-(int) getCurrentValue {
  return currentValue;
}

-(void) start {
  CCLOG(@"Timer start");
  // event Every interval(1sec as default)
  Timer = [NSTimer scheduledTimerWithTimeInterval:timer_interval target:self selector:@selector(timerTick:) userInfo:nil repeats:YES ];
  status = ggTimerSTAT_RUNNING;
}

-(void) pause {
  [Timer invalidate];
  status = ggTimerSTAT_STOPPED;
}

-(void) resume {
  if (status == ggTimerSTAT_STOPPED) {
    Timer = [NSTimer scheduledTimerWithTimeInterval:timer_interval target:self selector:@selector(timerTick:) userInfo:nil repeats:YES ];
    status = ggTimerSTAT_RUNNING;
  } else {
    CCLOG(@"ggTimerSTAT_STOPPED 인 경우에만 가능");
  }
}

@end
