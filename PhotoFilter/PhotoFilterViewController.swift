import UIKit
import CoreImage
import Photos
import CoreImage.CIFilterBuiltins

class PhotoFilterViewController: UIViewController {

	@IBOutlet weak var brightnessSlider: UISlider!
	@IBOutlet weak var contrastSlider: UISlider!
	@IBOutlet weak var saturationSlider: UISlider!
	@IBOutlet weak var imageView: UIImageView!
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale: CGFloat = 0.5 // UIScreen.main.scale - for every 2 points we have a pixel
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize)
            
            guard let scaledCGImage = scaledUIImage?.cgImage else { return }
            
            scaledImage = CIImage(cgImage: scaledCGImage)
        }
    }
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    private let context = CIContext()
    private let filter = CIFilter.colorControls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalImage = imageView.image
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        filter.inputImage = inputImage
        filter.saturation = saturationSlider.value
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        
        guard let outputImage = filter.outputImage else { return UIImage(ciImage: inputImage) }
        
        guard let renderedImage = context.createCGImage(outputImage, from: outputImage.extent) else { return UIImage(ciImage: inputImage) }
        
        
        return UIImage(cgImage: renderedImage)
    }
    
    private func updateImage() {
        if let originalImage = scaledImage {
            imageView.image = image(byFiltering: originalImage)
        }
        else {
            imageView.image = nil
        }
        
    }
	
	// MARK: Actions
	
	@IBAction func choosePhotoButtonPressed(_ sender: Any) {
		// TODO: show the photo picker so we can choose on-device photos
		// UIImagePickerController + Delegate
        presentImagePickerController()
	}
	
    private func presentImagePickerController() {
        // make sure photo library type is avalaible => may not work with restructions
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {
		// TODO: Save to photo library
	}
	

	// MARK: Slider events
	
	@IBAction func brightnessChanged(_ sender: UISlider) {
        updateImage()
	}
	
	@IBAction func contrastChanged(_ sender: Any) {
        updateImage()
	}
	
	@IBAction func saturationChanged(_ sender: Any) {
        updateImage()
	}
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
