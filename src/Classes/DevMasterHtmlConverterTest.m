//
//  DevMasterHtmlConverterTest.m
//  GDNet_ImageOfTheDay
//
//  Created by Zbigniew Kominek on 4/26/11.
//  Copyright 2011 zbyhoo. All rights reserved.
//

#import "DevMasterHtmlConverter.h"

@interface DevMasterHtmlConverterTest : GHTestCase
+ (NSString*)readSampleMainPageFile;
+ (NSString*)readSamplePostFile;
+ (NSString*)readPostPageFile;
@end

@interface DevMasterHtmlConverterMock : DevMasterHtmlConverter 
- (void)setCurrentPage:(int)value;
@end
@implementation DevMasterHtmlConverterMock
- (void)setCurrentPage:(int)value
{
    _currentPage = value;
}
- (NSString*)getData:(NSString*)urlString
{
    return [DevMasterHtmlConverterTest readPostPageFile];
}
@end

@implementation DevMasterHtmlConverterTest

+ (NSString*)readSampleMainPageFile 
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample_devmaster_main" ofType:@"html"]; 
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString*)readSamplePostFile 
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"devmaster_post" ofType:@"html"]; 
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString*)readPostPageFile 
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"devmaster_post_page" ofType:@"html"]; 
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (void)test_init
{
    // given
    id converterId = [DevMasterHtmlConverter alloc];
    
    // when
    DevMasterHtmlConverter *converter = [converterId init];
    
    // then
    GHAssertEquals(converter.templateUrl, @"http://www.devmaster.net/snapshot/index.php?start=", @"");
    GHAssertEquals(converter.step, 16, @"");
    GHAssertEquals(converter.currentPage, -16, @"");
    
    [converter release];
}

- (void)test_resetUrlCounter
{
    // given
    DevMasterHtmlConverterMock *converter = [[DevMasterHtmlConverterMock alloc] init];
    [converter setCurrentPage:32];
    
    // when
    [converter resetUrlCounter];
    
    // then
    GHAssertEquals(converter.currentPage, -converter.step, @"");
    
    [converter release];
}

- (void)test_getNextUrl
{
    // given
    DevMasterHtmlConverter *converter = [[DevMasterHtmlConverter alloc] init];
    
    // when
    NSString *url = [converter getNextUrl];
    
    // then
    NSString *expected = [NSString stringWithFormat:@"%@%d", converter.templateUrl, 0];
    GHAssertEqualObjects(url, expected, @"");
    
    [converter release];
}

- (void)test_getNextUrl_twice
{
    // given
    DevMasterHtmlConverter *converter = [[DevMasterHtmlConverter alloc] init];
    
    // when
    [converter getNextUrl];
    NSString *url = [converter getNextUrl];
    
    // then
    NSString *expected = [NSString stringWithFormat:@"%@%d", converter.templateUrl, converter.step];
    GHAssertEqualObjects(url, expected, @"");
    
    [converter release];
}

- (void)test_splitHtmlToPosts
{
    // given
    DevMasterHtmlConverter *converter = [[DevMasterHtmlConverter alloc] init];
    NSString *pageContent = [DevMasterHtmlConverterTest readSampleMainPageFile];
    
    // when
    NSArray *postChunks = [converter splitHtmlToPosts:pageContent];
    
    // then
    GHAssertNotNil(postChunks, @"");
    GHAssertEquals(postChunks.count, (NSUInteger)16, @"");
    
    [converter release];
}

- (void)test_parsePost
{
    // given
    DevMasterHtmlConverter *converter = [[DevMasterHtmlConverter alloc] init];
    NSString *postContent = [DevMasterHtmlConverterTest readSamplePostFile];
    
    // when
    NSDictionary *parsedPost = [converter parsePost:postContent];
    
    // then
    GHAssertNotNil(parsedPost, @"");
    GHAssertEqualObjects([parsedPost valueForKey:KEY_TITLE], @"Dot Boxing", @"");
    GHAssertEqualObjects([parsedPost valueForKey:KEY_AUTHOR], @"Chris", @"");
    GHAssertEqualObjects([parsedPost valueForKey:KEY_DATE], [NSNumber numberWithInt:1300575600], @"");
    GHAssertEqualObjects([parsedPost valueForKey:KEY_POST_URL], @"http://www.devmaster.net/snapshot/../forums/showthread.php?t=17215", @"");
    GHAssertEqualObjects([parsedPost valueForKey:KEY_IMAGE_URL], @"http://www.devmaster.net/snapshot/images/11-03-20.thm.jpg", @"");
    
    [converter release];
}

- (void)test_stringToTimestamp
{
    // given
    DevMasterHtmlConverter *converter = [[DevMasterHtmlConverter alloc] init];
    NSString *dateString = @"20 Mar 2011";
    
    // when
    NSNumber *timestamp = [converter stringToTimestamp:dateString];
    
    // then
    GHAssertNotNil(timestamp, @"");
    GHAssertEquals([timestamp intValue], 1300575600, @"");
    
    [converter release];
}

- (void)test_convertPost
{
    // given
    DevMasterHtmlConverter *converter = [[DevMasterHtmlConverterMock alloc] init];
    //Method m1 = class_getInstanceMethod(converter.class, @selector(getData:));
    //Method m2 = class_getInstanceMethod(self.class, @selector(getDataMock:));
    //method_exchangeImplementations(m1, m2);
    
    // when
    NSDictionary *convertedPost = [converter convertPost:nil];
    
    // then
    GHAssertNotNil(convertedPost, @"");
    GHAssertTrue([((NSString*)[convertedPost valueForKey:KEY_DESCRIPTION]) rangeOfString:@"As a personal project"].location != NSNotFound, @"");
    GHAssertTrue([((NSString*)[convertedPost valueForKey:KEY_DESCRIPTION]) rangeOfString:@"buisness card!"].location != NSNotFound, @"");
    GHAssertEqualObjects([convertedPost valueForKey:KEY_DATE], [NSNumber numberWithInt:1301180400], @"");
    NSString *key = [NSString stringWithFormat:@"%@%d", KEY_IMAGE_URL, 0];
    GHAssertEqualObjects([convertedPost valueForKey:key], @"http://www.devmaster.net/snapshot/images/11-03-25.jpg", @"");
    GHAssertEqualObjects([convertedPost valueForKey:KEY_IMAGES_COUNT], [NSNumber numberWithInt:1], @"");
    
    //method_exchangeImplementations(m1, m2);
    [converter release];
}

- (void)test_convertPostExactDate
{
    // given
    DevMasterHtmlConverter *converter = [[DevMasterHtmlConverter alloc] init];
    NSString *dateString = @"\n    03-27-2011, 02:00 AM\n    \n    ";
    
    // when
    NSNumber *timestamp = [converter convertPostExactDate:dateString];
    
    // then
    GHAssertNotNil(timestamp, @"");
    GHAssertEquals([timestamp intValue], 1301180400, @"");
    
    [converter release];
}

@end