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
#import "ggTimer.h"

typedef enum {
  ggStatusINIT,
  ggStatusReadyToTouch,
  ggStatusInAnimation,
  ggStatusStopTheGame
} ggStatus;

// Notification Events 
#define GG_NOTIFICATION_SCORE_UPDATE @"ggEVENT_ScoreUpdate"
#define GG_NOTIFICATION_GAME_OVER    @"ggEVENT_GameOver"
#define GG_NOTIFICATION_TIME_EVENT   @"ggEVENT_TimeEvent"

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
  int        GameMadeGems;
  int        GameMadeBonusGems;
  int        GameScodeAdd;
  int        GameScodeBonus;
  
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
  ggConfigStruct      ggConfig;
  ggTimer             *_thisTimer;
  
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
-(void) __fillBlank:(NSMutableDictionary *)blankColumns;
-(BOOL) __isPossible:(NSMutableDictionary *)_tempBoard;
-(void) __afterAnimations; 
-(NSMutableDictionary *) __gravityJob:(NSMutableArray *)gems;
-(ggGem *) __registAGemTypeof:(int)gemType AtPositionAsNSValue:(NSValue *)posAsVal onBoard:(NSMutableDictionary *)targetBoard;

//unit convert
-(CGPoint) __TopReadyPosition_NSValue2CGPoint:(NSValue *)value;
-(CGPoint) __Position_NSValue2CGPoint:(NSValue *)value;
-(NSMutableDictionary *) __GemsArray2Dictionary:(NSMutableArray *) gems;

//GameType1 :
-(void) goGemBurst:(NSValue *)posInBoard;
-(void) GemContinuous:(NSValue *)posAsNSValue gemType:(int)thisType refArray:(NSMutableArray* )gems fromBoard:(NSMutableDictionary *)tempBoard;
-(BOOL) isSameGem:(int)thisType withPos:(NSValue *)posAsNSValue fromBoard:(NSMutableDictionary *)tempBoard;

//GameType2 :
//replace between posA and posB
@end
