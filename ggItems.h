//
//  ggItems.h
//  gemgem
//
//  Created by Yong-uk Choe on 12. 12. 8..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ggConfig.h"

@interface ggItems : NSObject
{
  NSMutableArray *items;
  CCLayer        *_thisCCLayer;
  CGPoint        _anchorPoint;
}

-(id) initWithCCLayer:(CCLayer *)cclayer at_y:(float)positionY;

//-(void) addItem:(int)itemType;

-(void) pushItem:(int)itemType;
-(NSMutableArray *) popItem;

-(BOOL) touchesEnded:(CGPoint)toucheslocation;

@end
