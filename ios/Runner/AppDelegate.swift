import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let METHOD_CHANNEL_NAME = "co.wawand/stripe"
        
        let stripeChannel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)
        
        stripeChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "test":
                guard let args = call.arguments as? [String: String] else {return}
                let name = args["name"]!
                result("IOS say hello \(name)")
            default:
                result(FlutterMethodNotImplemented)
            }
            
            
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func initializeStripe(name: String?) -> String {
        return name ?? "Hey from IOs project!"
    }
}
