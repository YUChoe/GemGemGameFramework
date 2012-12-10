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
  
}

-(id) initWithCCLayer:(CCLayer *)cclayer at_x:(float)positionX;

//-(void) addItem:(int)itemType;

-(void) pushItem:(int)itemType;
-(NSMutableArray *) popItem;

@end
