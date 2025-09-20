import Foundation

// MARK: - Account Images Data
struct AccountImageData {
    static let images: [AccountImage] = [
        AccountImage(id: "image1", imageName: "pic1"),
        AccountImage(id: "image2", imageName: "pic2"),
        AccountImage(id: "image3", imageName: "pic3"),
        AccountImage(id: "image4", imageName: "pic4"),
        AccountImage(id: "image5", imageName: "pic5"),
        AccountImage(id: "image6", imageName: "pic6"),
        AccountImage(id: "image7", imageName: "pic7"),
        AccountImage(id: "image8", imageName: "pic8"),
        AccountImage(id: "image9", imageName: "pic9"),
        AccountImage(id: "image10", imageName: "pic10"),
        AccountImage(id: "image11", imageName: "pic11"),
        AccountImage(id: "image12", imageName: "pic12")
    ]
    
    static func image(at index: Int) -> AccountImage {
        let imageIndex = index % images.count
        return images[imageIndex]
    }
}

// MARK: - Account Image Model
struct AccountImage: Identifiable, Codable {
    let id: String
    let imageName: String
}

// MARK: - Account Extensions for Images
extension Account {
    var cardImage: String {
        let imageIndex = designIndex % AccountImageData.images.count
        return AccountImageData.images[imageIndex].imageName
    }
}
