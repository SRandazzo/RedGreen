
/**  XCTestLog+RedGreen.m  *//* © 𝟮𝟬𝟭𝟯 𝖠𝖫𝖤𝖷 𝖦𝖱𝖠𝖸  𝗀𝗂𝗍𝗁𝗎𝖻.𝖼𝗈𝗆/𝗺𝗿𝗮𝗹𝗲𝘅𝗴𝗿𝗮𝘆 */

#import "XCTestLog+RedGreen.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <stdarg.h>

#define CLR_BEG "\033[fg"
#define CLR_END "\033[;"
#define CLR_WHT "239,239,239"
#define CLR_GRY "150,150,150"
#define CLR_WOW "241,196,15"
#define CLR_GRN "46,204,113"
#define CLR_RED "211,84,0"

static BOOL isXcodeColorsEnabled;

NSString *const kXCTestCaseFormat 				= @"Test Case '%@' %s (%.3f seconds).\n";
NSString *const kXCTestSuiteStartFormat		= @"Test Suite '%@' started at %@\n";
NSString *const kXCTestSuiteFinishFormat 		= @"Test Suite '%@' finished at %@.\n";
NSString *const kXCTestSuiteFinishLongFormat	= @"Test Suite '%@' finished at %@.\n";

NSString *const kRGTestCaseFormat = @"%@: %s (%.3fs)";
NSString *const kXCTestErrorFormat = @"%@:%@: error: %@ : %@\n";

NSString *const kXCTestCaseArgsFormat = @"%@|%s|%.5f";
NSString *const kXCTestErrorArgsFormat = @"%@|%@|%@|%@";
NSString *const kRGArgsSeparator = @"|";

NSString *const kXCTestPassed = @"PASSED";
NSString *const kXCTestFailed = @"FAILED";

NSString *const kRGColorGreen = @"0,160,0";
NSString *const kRGColorRed = @"225,0,0";

NSString *const kRGTestCaseXCOutputFormat = @""CLR_BEG"%@;%@:"CLR_END CLR_BEG CLR_GRY";%@ "CLR_END CLR_BEG CLR_WHT ";%@" CLR_END CLR_BEG CLR_GRY ";] (%@s)" CLR_END "\n";

NSString *const kRGTestCaseOutputFormat = @"%@: %@ (%@s)\n";
NSString *const kRGTestErrorXCOutputFormat 	= @"\t\033[fg%@;Line %@: %@\033[;\n";
NSString *const kRGTestErrorOutputFormat 		= @"\tLine %@: %@\n";

@implementation XCTestLog (RedGreen)

+ (void)load
{
    Method _testLogWithFormat = class_getInstanceMethod(self, @selector(testLogWithFormat:));
    Method _testLogWithColorFormat = class_getInstanceMethod(self, @selector(testLogWithColorFormat:));
    
    method_exchangeImplementations(_testLogWithFormat, _testLogWithColorFormat);
    
    char *xcode_colors = getenv("XcodeColors");
    isXcodeColorsEnabled = (xcode_colors && (strcmp(xcode_colors, "YES") == 0));
}

+ (NSMutableArray *)errors
{
    static dispatch_once_t pred;
    static NSMutableArray *_errors = nil;
    dispatch_once(&pred, ^{ _errors = [[NSMutableArray alloc] init]; });
    return _errors;
}

+ (NSString *)updatedOutputFormat:(NSString *)format
{
    if ([format isEqualToString:kXCTestCaseFormat]) {
        return kRGTestCaseFormat;
    }
    
    return format;
}

- (void)testLogWithColorFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    if ([format rangeOfString:@"started."].location != NSNotFound) {
        return;
    }
    
    va_list arguments;
    va_start(arguments, format);
    
    if ([@[	@"Test Case '%@' started.\n",	@"Test Suite '%@' started at %@\n",	kXCTestSuiteFinishLongFormat] containsObject:format]) {
        
		if (PRINT_START_FINISH_NOISE)
			isXcodeColorsEnabled 	? printf(CLR_BEG CLR_GRY "%s" CLR_END, [[NSString stringWithFormat:format,arguments] UTF8String])
            : printf("%s",[[NSString stringWithFormat:format,arguments]UTF8String]);
        
	}
    else if ([format isEqualToString:kXCTestCaseFormat]) {
        NSArray *args = [[NSString.alloc initWithFormat:kXCTestCaseArgsFormat arguments:arguments] componentsSeparatedByString:kRGArgsSeparator];
		NSArray *methodParts = [args[0] componentsSeparatedByString:@" "];
		NSString *log = args[1];
        
        NSString *color = [NSString stringWithUTF8String:[log.uppercaseString isEqualToString:kXCTestPassed] ? CLR_GRN : CLR_RED];
        
        NSString *messenger = methodParts[0];
        
        NSString *method = [methodParts[1] stringByReplacingOccurrencesOfString:@"]" withString:@""];
        
        NSString *output = isXcodeColorsEnabled ? [NSString stringWithFormat:kRGTestCaseXCOutputFormat, color, log.uppercaseString, messenger, method, SHOW_SECONDS ? args[2] : @""]
        : [NSString stringWithFormat:kRGTestCaseOutputFormat, log.uppercaseString, args[0], SHOW_SECONDS ? args[2] : @""];

        
        printf("%s", output.UTF8String);
        
        if ([XCTestLog errors].count > 0) {
            for (NSString *error in [XCTestLog errors]) {
                printf("%s", error.UTF8String);
            }
            
            [[XCTestLog errors] removeAllObjects];
        }
    } else if ([format isEqualToString:kXCTestErrorFormat]) {
        NSArray *args = NSArrayFromArguments(arguments);
        
        NSString *output = isXcodeColorsEnabled ? [NSString stringWithFormat:kRGTestErrorXCOutputFormat, kRGColorRed, args[1], args[3]] :
        [NSString stringWithFormat:kRGTestErrorOutputFormat, args[1], args[3]];
        [[XCTestLog errors] addObject:output];
        
    } else {
        [self testLogWithFormat:format arguments:arguments];
    }
    
    va_end(arguments);
}

NSArray *NSArrayFromArguments(va_list arguments)
{
    NSString *s = [[NSString alloc] initWithFormat:kXCTestErrorArgsFormat arguments:arguments];
    NSArray *args = [s componentsSeparatedByString:kRGArgsSeparator];
    
    return args;
}


@end