//
//  ContentView.swift
//  Instafilter
//
//  Created by Bruke on 7/26/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
        
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showFilterSheet: Bool = false
    @State private var filter: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tape to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in
                            applyProcessing()
                        }
                        .disabled(disableSlider(image: image))
                        .accentColor(disableSlider(image: image) == true ? .gray : .blue)
                }
                .padding(.vertical)
                
                HStack {
                    HStack {
                        Button("Change filter: ") {
                            showFilterSheet = true
                        }
                        
                        Text("\(filter)")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in
                loadImage()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showFilterSheet) {
                Button("Crystalize") {
                    setFilter(CIFilter.crystallize())
                    filter = "Crystalize"
                }
                
                Button("Eges") {
                    setFilter(CIFilter.edges())
                    filter = "Eges"
                }
                
                Button("Guassian Blur") {
                    setFilter(CIFilter.gaussianBlur())
                    filter = "Guassian Blur"
                }
                
                Button("Pixellate") {
                    setFilter(CIFilter.pixellate())
                    filter = "Pixellate"
                }
                
                Button("Sepia Tone") {
                    setFilter(CIFilter.sepiaTone())
                    filter = "Sepia Tone"
                }
                
                Button("Unsharp Mask") {
                    setFilter(CIFilter.unsharpMask())
                    filter = "Unsharp Mask"
                }
                
                Button("Vignette") {
                    setFilter(CIFilter.vignette())
                    filter = "Vignette"
                }
                
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        print(inputImage)
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func disableSlider(image: Image?) -> Bool {
        if image == nil {
            return true
        } else {
            return false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
