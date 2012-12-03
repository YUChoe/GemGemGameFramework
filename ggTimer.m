//
//  ggTimer.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 12. 3..
//
//

#import "ggTimer.h"

@implementation ggTimer

-(id) initWithCCLayer:(CCLayer *)cclayer {
  if ( self = [super init] ) {
    [self __initSprites];

    // default setting
    currentValue = 60; // = 100%
    warningPoint = 30; // = 50%
    dangerPoint = 15;  // = 25%
    
    timer_interval = 1.0f; // 1 second
    
    status = ggTimerSTAT_STOPPED;
    
    // event Every interval(1sec as default)
    Timer = [NSTimer scheduledTimerWithTimeInterval:timer_interval target:self selector:@selector(timerTick) userInfo:nil repeats:NO ];
    
  }
  return self;
}

-(void) timerTick:(NSTimer *)sender {
  // animation
  
  
}


-(void) __initSprites {
  CGSize screen_size = [[CCDirector sharedDirector] winSize];

  bar1 = [CCSprite spriteWithFile:@"timer_bar_green.png"];
  bar2 = [CCSprite spriteWithFile:@"timer_bar_yellow.png"];
  bar3 = [CCSprite spriteWithFile:@"timer_bar_red.png"];
  
  bar1.position = timerPosition;
  bar2.position = timerPosition;
  bar3.position = timerPosition;
  
  // green
  bar1.anchorPoint = ccp(0, 0.5f); // 좌하(0, 0), 우상(1, 1)
  bar1.scaleX = bar1.contentSize.width * screen_size.width / 100; // screen_size.width
  bar1.scaleY = bar1.contentSize.height * 30 / 100; // 30px;


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
  
}

-(void) pause {
  
}

-(void) resume {
  
}

@end
