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
  if (itemType == 0) { // test
    //@"item_default.png"
    filename = @"pause.png";
  }
  CCSprite *s = [CCSprite spriteWithFile:filename];
  s.position = ccpAdd(_anchorPoint, ccp((70 * [items count]),0));
  [_thisCCLayer addChild:s];
  // 등장 animation
  
  //
  [i addObject:s];
  
  [items addObject:i];
}

-(NSMutableArray *) popItem {
  NSMutableArray *i;
  if ([items count] > 0) {
    i = [items objectAtIndex:0];
    //    [items remove at index:0];
    return i;
  } else {
    CCLOG(@"no more items");
    return nil;
  }

}

@end
