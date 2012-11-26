//
//  ggObject.h
//  gemgemCCScene
//
//  Created by Yong-uk Choe on 12. 11. 24..
//
//

#import <Foundation/Foundation.h>
#import "ggConfig.h"
#import "ggGem.h"


typedef enum {
  ggStatusINIT,
  ggStatusReadyToTouch,
  ggStatusInAnimation
} ggStatus;


struct ggBoardStruct
{
  BOOL isEmpty;
  ggGem *Gem;
  int gemType;
  CGPoint position;
  
};
typedef struct ggBoardStruct ggBoardStruct;

@interface ggObject : NSObject
{
  NSMutableDictionary *_ggConfig;
  CCLayer             *_thisCCLayer;
  NSMutableDictionary *_board;
  ggStatus            _thisStatus;
  //BOOL                localAnimationStatus;
  int                 _thisGameType;
}

// init, status
-(id) initWithCCLayer:(CCLayer *)_layer;
-(ggStatus) getStatus;

// configuration
-(NSObject *) getConfig:(NSString *)keyString;
-(void) setConfig:(NSString *)keyString value:(id)valueObject;
-(void) loadDefaultConfiguration;

-(void) run;

-(void) touchesEnded:(CGPoint)touchedLocation;
-(BOOL) isTouchAvailable:(CGPoint)position;

//내부 메소드 for init
-(void) __dropGemsForFirstTime;
-(void) __drawBoard;

//내부 메소드 for game playing
-(int) __findBottom:(int)columnNumber;
-(int) __dropGemAtColumn:(int)columnNumber;

//GameType1 :
-(BOOL) isGemBurstable:(NSValue *)posInBoard;
// has connection

//GameType2 :
//replace between posA and posB
@end
