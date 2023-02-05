//
//  SpotDetailPhotoScrollView.swift
//  Snacktackular
//
//  Created by Jeremy Taylor on 2/5/23.
//

import SwiftUI

struct SpotDetailPhotoScrollView: View {
//    struct FakePhoto: Identifiable {
//        let id = UUID().uuidString
//        var imageURLString = "https://firebasestorage.googleapis.com:443/v0/b/snacktackular-e8176.appspot.com/o/5GWkDdnP5Vr81QBn4CVf%2F8DA0D1C7-B2CF-4267-A5CF-D08EC6890B93.jpeg?alt=media&token=73f10c6b-eba4-4e84-bb13-e919bc425238"
//    }
//
//    let photos = [FakePhoto(), FakePhoto(),FakePhoto(),FakePhoto(),FakePhoto(),FakePhoto(),FakePhoto(),FakePhoto(),]
    @State private var showPhotoViewerView = false
    @State private var uiImage = UIImage()
    @State private var selectedPhoto = Photo()
    var photos: [Photo]
    var spot: Spot
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 4) {
                ForEach(photos) { photo in
                    let imageURL = URL(string: photo.imageURLString) ?? URL(string: "")
                    
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .onTapGesture {
                                let renderer = ImageRenderer(content: image)
                                selectedPhoto = photo
                                uiImage = renderer.uiImage ?? UIImage()
                                showPhotoViewerView.toggle()
                            }
                    } placeholder: {
                        ProgressView()
                            .frame(width: 80, height: 80)
                    }

                }
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 4)
        .sheet(isPresented: $showPhotoViewerView) {
            PhotoView(photo: $selectedPhoto, uiImage: uiImage, spot: spot)
        }
    }
}

struct SpotDetailPhotoScrollView_Previews: PreviewProvider {
    static var previews: some View {
        SpotDetailPhotoScrollView(photos: [Photo(imageURLString: "https://firebasestorage.googleapis.com:443/v0/b/snacktackular-e8176.appspot.com/o/5GWkDdnP5Vr81QBn4CVf%2F8DA0D1C7-B2CF-4267-A5CF-D08EC6890B93.jpeg?alt=media&token=73f10c6b-eba4-4e84-bb13-e919bc425238")], spot: Spot(id: "5GWkDdnP5Vr81QBn4CVf"))
    }
}
