#import "CSWindow.h"

typedef void(^RecordMyScreenCallback)(void);

@interface CSRecordQueryWindow : CSWindow
@property (nonatomic, copy) RecordMyScreenCallback onConfirmation;
@end