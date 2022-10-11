#import "FlutterQrPlugin.h"

#if __has_include(<qr_code_scan_pay/qr_code_scan_pay-Swift.h>)
#import <qr_code_scan_pay/qr_code_scan_pay-Swift.h>
#else
#import "qr_code_scan_pay-Swift.h"
#endif

@implementation FlutterQrPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftFlutterQrPlugin registerWithRegistrar:registrar];
}
@end
