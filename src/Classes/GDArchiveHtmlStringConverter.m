//
//  GDArchiveHtmlStringConverter.m
//  GDNet_ImageOfTheDay
//
//  Created by Zbigniew Kominek on 2/16/11.
//  Copyright 2011 zbyhoo. All rights reserved.
//

#import "GDArchiveHtmlStringConverter.h"
#import "Constants.h"
#import "Utilities.h"
#import "GDImagePost.h"

NSUInteger helperIndex = 60;

@implementation GDArchiveHtmlStringConverter

+ (void)setHelperIndex:(int)index {
    helperIndex = index;
}

- (NSMutableArray*)splitHtmlToPosts:(NSString*)htmlPage {
    NSMutableArray *chunks = [NSMutableArray arrayWithArray:[htmlPage componentsSeparatedByString:GD_ARCHIVE_POST_SEPARATOR]];
    
    if ([chunks count] <= 1) {
        LogWarning(@"no post sections found");
    }
    else {
        [chunks removeObjectAtIndex:0];  
        NSString* last = [chunks lastObject];
        last = [[last componentsSeparatedByString:GD_ARCHIVE_LAST_POST_SEPARATOR] objectAtIndex:0];
        [chunks replaceObjectAtIndex:([chunks count] - 1) withObject:last];
    }
    
    LogDebug(@"before filtering:\n%@", chunks);
    [chunks filterUsingPredicate:[self isPostLikePredicate]];
    LogDebug(@"after filtering:\n%@", chunks);
    
    return chunks;
}

- (NSPredicate*)isPostLikePredicate {
    return [NSPredicate predicateWithFormat:@"SELF MATCHES '.*Posted.*By.*(a title).*Comment(s)*.*'"];
}                                            

- (NSDictionary*)parsePost:(NSString*)chunk {    
    NSRange range;
    range.location = 0;
    range.length = chunk.length - 1;
    
    NSNumber *date;
    NSString *user;
    NSString *postUrl;
    NSString *title;
    NSString *imgUrl;
    
    @try {
        NSString *dateString = [Utilities getSubstringFrom:chunk range:&range after:GD_ARCHIVE_DATE_START before:GD_ARCHIVE_DATE_END];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];
        double timestamp = [[df dateFromString: dateString] timeIntervalSince1970];
        timestamp += (helperIndex--); // trick to properly sort posts by timestamp (here we have only day, no exact time)
        if (helperIndex == 0) {
            helperIndex = 60;
        }
        date = [NSNumber numberWithDouble:timestamp];
        [df release];
        LogDebug(@"Date: %@", date);
        
        user = [Utilities getSubstringFrom:chunk range:&range after:GD_ARCHIVE_USER_START before:GD_ARCHIVE_USER_END];
        LogDebug(@"User: %@", user);
        
        postUrl = [Utilities getSubstringFrom:chunk range:&range after:GD_ARCHIVE_URL_START before:GD_ARCHIVE_URL_END];
        postUrl = [NSString stringWithFormat:@"%@%@", GD_ARCHIVE_POST_URL, postUrl];
        LogDebug(@"Post URL: %@", postUrl);
        
        title = [Utilities getSubstringFrom:chunk range:&range after:GD_ARCHIVE_TITLE_START before:GD_ARCHIVE_TITLE_END];
        LogDebug(@"Title: %@", title);
        
        imgUrl = [Utilities getSubstringFrom:chunk range:&range after:GD_ARCHIVE_IMG_URL_START before:GD_ARCHIVE_IMG_URL_END];
        LogDebug(@"Image Url: %@", imgUrl);
    }
    @catch (NSException * e) {
        LogError(@"error with parsing post:\n%@", chunk);
        return nil;
    }
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:date forKey:KEY_DATE];
    [dict setValue:user forKey:KEY_AUTHOR];
    [dict setValue:postUrl forKey:KEY_POST_URL];
    [dict setValue:title forKey:KEY_TITLE];
    [dict setValue:imgUrl forKey:KEY_IMAGE_URL];
    
    return [dict autorelease];
}

@end
