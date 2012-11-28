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

// Notification Events 
#define GG_NOTIFICATION_SCORE_UPDATE @"ggEVENT_ScoreUpdate"

struct ggBoardStruct
{
  BOOL isEmpty;
  ggGem *Gem;
  int gemType;
  CGPoint position;
};
typedef struct ggBoardStruct ggBoardStruct;

struct ggConfigStruct {
  // Game
  int        GameType;
  
  // Gem
  int        GemTypeCount;
  int        GemSizeBYPixel;
  
  // Board
  int        BoardWidth;
  int        BoardHeight;
  CGPoint    BoardAnchorPosition;
  
};
typedef struct ggConfigStruct ggConfigStruct;

@interface ggObject : NSObject
{
  NSMutableDictionary *_ggConfig;
  CCLayer             *_thisCCLayer;
  NSMutableDictionary *_board;
  ggStatus            _thisStatus;
  //BOOL                localAnimationStatus;
  int                 _thisGameType;
  int                 _gameScore;
  
  CGPoint             _lastEventTouchPoint;
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

-(int) getScore;
-(void) setScore:(int)newScore;

//내부 메소드 for init
-(void) __dropGemsForFirstTime;
-(void) __drawBoard;

//내부 메소드 for game playing
-(int) __findBottom:(int)columnNumber;
-(CCAction *) __gemDropAtColumn:(int)columnNumber bottom:(int)bottom;

-(NSMutableDictionary *) __gravityJob:(NSMutableArray *)gems;

//GameType1 :
-(void) goGemBurst:(NSValue *)posInBoard;
-(void) GemContinuous:(NSValue *)posAsNSValue gemType:(int)thisType refArray:(NSMutableArray* )gems;

//GameType2 :
//replace between posA and posB
@end
