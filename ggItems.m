//
//  ggItems.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 12. 8..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "ggItems.h"


@implementation ggItems

-(id) initWithCCLayer:(CCLayer *)cclayer at_y:(float)positionY {
  if ( self = [super init] ) {
    items = [[NSMutableArray alloc] init];
    _thisCCLayer = cclayer;
    _anchorPoint = CGPointMake(30, positionY);
  }
  return self;
}

-(void) pushItem:(int)itemType {
  NSMutableArray *i = [[NSMutableArray alloc] init];
  
  NSString *filename = [NSString stringWithFormat:@"item_%d.png", itemType];
  CCLOG(@"new item : filename(%@)", filename);
  //if (itemType == 0) { // test
    //@"item_default.png"
    filename = @"pause.png";
  //}
  CCSprite *s = [CCSprite spriteWithFile:filename];
  // starting position
  s.position = ccpAdd(_anchorPoint, ccp(70 * 5,0));
  [_thisCCLayer addChild:s];
  // 등장 animation
  [s runAction:[CCMoveTo actionWithDuration:0.5f position:ccpAdd(_anchorPoint, ccp((70 * [items count]),0))]];
  //
  [i addObject:s];                                 // idx:0
  [i addObject:[NSNumber numberWithInt:itemType]]; // idx:1
  
  //
  [items addObject:i];
}

-(NSMutableArray *) popItem {
  NSMutableArray *i;
  if ([items count] > 0) {
    i = [items objectAtIndex:0];
    /*
    CCSprite *s = [i objectAtIndex:0];
    // remove sprite animation
    [s runAction:[]];
    //remove from layer 
    [_thisCCLayer removeChild:s cleanup:YES];
    */
    //
    [items removeObjectAtIndex:0];
    
    [self _reOrderItems];
    
    return i;
  } else {
    CCLOG(@"popItem:no more items");
    return nil;
  }

}

-(void) _reOrderItems {
  // pop 된 이후(removeObjectAtIndex) 니까
  // 인덱스가 이미 1씩 빠져 있음
  // 그러나 애니메이션이나 board 처리 객체에서의 작업이 안 끝났을 수도있음
  for(int idx=0; idx < [items count]; idx++) {
    CCSprite *s = [[items objectAtIndex:idx] objectAtIndex:0];
    [s runAction:[CCMoveTo actionWithDuration:0.3f position:ccpAdd(_anchorPoint, ccp((70 * idx),0))]];
  }
}

-(BOOL) touchesEnded:(CGPoint)toucheslocation {
  for (int idx=0; idx<[items count]; idx++) {
    NSMutableArray *i = [items objectAtIndex:idx];
    CCSprite *s = [i objectAtIndex:0];
    
    if (CGRectContainsPoint(s.boundingBox, toucheslocation)) {
      CCLOG(@"touched item[%d]_%d", idx, [[i objectAtIndex:1] intValue]);
      // 사용 후 제거
      // pop 애니메이션
      return YES;
    }
  }
  return NO;
}
@end
