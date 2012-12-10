//
//  ggItems.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 12. 8..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "ggItems.h"


@implementation ggItems

-(id) initWithCCLayer:(CCLayer *)cclayer at_x:(float)positionX {
  if ( self = [super init] ) {
    items = [[NSMutableArray alloc] init];
  }
  return self;
}

-(void) pushItem:(int)itemType {
  NSMutableArray *i = [[NSMutableArray alloc] init];
  
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
