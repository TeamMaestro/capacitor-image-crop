import Foundation
import Capacitor
import CropViewController
typealias JSObject = [String:Any]
@objc(ImageCropPlugin)
public class ImageCropPlugin: CAPPlugin, CropViewControllerDelegate {
    var id: String?
    @objc func show(_ call: CAPPluginCall) {
        let source = call.getString("source") ?? ""
        let width = call.getInt("width") ?? 0
        let height = call.getInt("height") ?? 0
        let lock = call.getBool("lock") ?? false
        let ratio = call.getString("ratio") ?? ""


        if(source == ""){
            call.reject("Invalid source")
        }

        id = call.callbackId
        call.save()


        DispatchQueue.main.async {
            let vc : CropViewController?

            if(source.starts(with: "~")){
                vc = CropViewController.init(image: UIImage(named: (Bundle.main.resourceURL?.path)! + "/public" + source.replacingOccurrences(of: "~", with: ""))!)
            }else{
                vc = CropViewController.init(image: UIImage(named: URL(fileURLWithPath: source).path)!)
            }

            vc?.delegate = self
            if(lock){
                vc?.aspectRatioLockEnabled = true
                vc?.resetAspectRatioEnabled = false
                vc?.aspectRatioPickerButtonHidden = true;
                vc?.aspectRatioPreset = CropViewControllerAspectRatioPreset.presetSquare
            }

            self.bridge.viewController.present(vc!, animated: true, completion: {
                if(width > 0 && height > 0){
                    vc?.toolbar.clampButtonHidden = true;
                    let gcd = ImageCropPlugin.gcd(width: width, height: height)
                    if(ratio != ""){
                        let r = ratio.split(separator: ":")
                        vc?.cropView.setAspectRatio(CGSize(width: Int(r[0])!, height: Int(r[1])!), animated: false)
                    }else{
                        vc?.cropView.setAspectRatio(CGSize(width: width / gcd, height: height / gcd), animated: false)
                    }

                }
            })
        }
    }


    private static func gcd(width: Int, height: Int) -> Int {
        if (height == 0) {
            return width;
        } else {
            return gcd(width:height, height:width % height);
        }
    }

    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        let call = self.bridge.getSavedCall(self.id!)
        do {
            if(call != nil){
                let path = URL.init(fileURLWithPath: FileManager.default.temporaryDirectory.path + "/" + NSUUID().uuidString + ".jpg")
                let width = call?.getInt("width") ?? 0
                let height = call?.getInt("height") ?? 0
                if(width > 0 && height > 0 ){
                    let rect = CGRect(x: 0, y: 0, width: width, height: height)
                    UIGraphicsBeginImageContext(rect.size)
                    image.draw(in: rect)
                    let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    try UIImageJPEGRepresentation(resizeImage!, 1.0)?.write(to: path, options: Data.WritingOptions.atomic)
                }else{
                    try UIImageJPEGRepresentation(image, 1.0)?.write(to: path, options: Data.WritingOptions.atomic)
                }
                var object = JSObject()
                object["value"] = CAPFileManager.getPortablePath(uri: path)
                call?.resolve(object)
            }

        } catch let e {
            if(call != nil){
                call?.reject(e.localizedDescription)
            }
        }
    }

    public func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
