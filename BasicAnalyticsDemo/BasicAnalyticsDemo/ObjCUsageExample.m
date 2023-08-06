#import <Foundation/Foundation.h>
#import "ObjCUsageExample.h"
#import "BasicAnalyticsDemo-Swift.h"

@import BasicAnalytics;

@implementation ObjectiveCAnalyticsUsageClass
- (void)callSwiftMethodsFromAnalytics {
    BAConfiguration *config = [[BAConfiguration alloc] initWithWritingKey:@"123"];
    BAAnalytics *analytics = [[BAAnalytics alloc] initWithConfiguration: config];
    [analytics startSessionWithCompletion:^{
        BAEvent *event = [[BAEvent alloc] initWithName:@"ObjC initialized event"];
        [analytics trackEvent: event];
        
        [analytics endSessionWithCompletion:^{
            [analytics printLastSession];
        } onError:^(enum AnalyticsError error) {
            
        }];
    } onError:^(enum AnalyticsError error) {
        
    }];
}
@end
