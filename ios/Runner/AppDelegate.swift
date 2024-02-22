import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var navigationController: UINavigationController!
    
    var stripeChannel: FlutterMethodChannel!
    
    override func application(
        
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = self.window?.rootViewController as! FlutterViewController
        
        linkNativeCode(controller: controller)
        
        GeneratedPluginRegistrant.register(with: self)
        self.navigationController = UINavigationController(rootViewController: controller)
        self.window.rootViewController = self.navigationController
        self.navigationController.setNavigationBarHidden(false, animated: false)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate {
    func linkNativeCode(controller: FlutterViewController){
        setupMethodChannelForStripe(controller: controller)
    }
    
    private func setupMethodChannelForStripe(controller: FlutterViewController){
        let METHOD_CHANNEL_NAME = "co.wawand/stripe"
        
        stripeChannel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)
        
        stripeChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "test":
                guard let args = call.arguments as? [String: Any] else {return}
                let stripePublishableKey = args["stripePublishableKey"] as! String
                let backendURL = args["serverHost"] as! String
                let amount = args["amount"] as! String
                let cartItems = args["cartItems"] as! [[String]]

                let vc = UIStoryboard.init(name: "Main", bundle: .main).instantiateViewController(identifier: "CheckoutViewController") as! CheckoutViewController
                vc.stripePublishableKey = stripePublishableKey
                vc.serverHost = backendURL
                vc.amount = amount
                vc.cartItems = cartItems
                vc.result = result
                self.navigationController.pushViewController(vc, animated: true)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
}
