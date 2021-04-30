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

        if let args = call.arguments as? Dictionary<String, Any>,
            let quality = args["quality"] as? NSNumber ,
            let format = args["format"] as? String {
            takeScreenshot(view: controller.view, quality: quality, format: format)
        } else {
            result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }

    } // handle()

    func takeScreenshot(view: UIView, quality: NSNumber, format: String) {
        let scale: CGFloat = UIScreen.main.scale

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)

        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let optionalImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let image = optionalImage else {
            result(nil)
            return
        } // guard no image

        if (format == "jpeg"){
            NSLog("[Native Screenshot iOS] Taking screenshot in jpeg format with quality \(quality)")
            let q = (quality as! CGFloat) / 100
            let data = FlutterStandardTypedData(bytes: image.jpegData(compressionQuality: q)!)
            result(data)
        } else if (format == "png"){
            NSLog("[Native Screenshot iOS] Taking screenshot in png format")
            let data = FlutterStandardTypedData(bytes: image.pngData()!)
            result(data)
        } else {
            NSLog("[Native Screenshot iOS] Unsupported image format: \(format)")
            result(nil)
        }
    } // takeScreenshot()
} // SwiftNativeScreenshotPlugin
