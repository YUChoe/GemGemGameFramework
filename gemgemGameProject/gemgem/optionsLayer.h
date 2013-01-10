//
//  optionsLayer.h
//  gemgem
//
//  Created by Yong-uk Choe on 12. 11. 30..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface optionsLayer : CCLayer {  
  NSString *plist_path;
  NSData *plist_Data;
  
  BOOL _isBackgroundMusicON;
  BOOL _isEffectSoundON;
}

+(CCScene *) scene;

@end
