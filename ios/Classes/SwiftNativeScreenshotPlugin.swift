import Flutter
import UIKit

public class SwiftNativeScreenshotPlugin: NSObject, FlutterPlugin {
    var controller :FlutterViewController!
    var messenger :FlutterBinaryMessenger
    var result :FlutterResult!
    var screenshotPath :String!

    init(controller: FlutterViewController, messenger: FlutterBinaryMessenger) {
        self.controller = controller
        self.messenger = messenger

        super.init()
    } // init()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_screenshot", binaryMessenger: registrar.messenger())

        let app = UIApplication.shared
        let controller :FlutterViewController = app.delegate!.window!!.rootViewController as! FlutterViewController

        let instance = SwiftNativeScreenshotPlugin(
            controller: controller,
            messenger: registrar.messenger()
        ) // let instance

        registrar.addMethodCallDelegate(instance, channel: channel)
    } // register()

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method != "takeScreenshot" {
            result(FlutterMethodNotImplemented)

            return
        } // if

        self.result = result

        takeScreenshot(view: controller.view)
    } // handle()

    func takeScreenshot(view: UIView, toImageGallery :Bool = true) {
        let scale :CGFloat = UIScreen.main.scale

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)

        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let optionalImage :UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let image = optionalImage else {
            result(nil)
            return
        } // guard no image

        let data = FlutterStandardTypedData(bytes: image.pngData()!)
        result(data)

    } // takeScreenshot()
} // SwiftNativeScreenshotPlugin
