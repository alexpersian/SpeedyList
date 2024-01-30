import UIKit

class Asset {
    let id: String
    let image: UIImage

    init(id: String, image: UIImage) {
        self.id = id
        self.image = image
    }
}

final class ImageCache {

    private let cache = NSCache<NSString, UIImage>()
    private let lock = NSLock()

    func storeImage(_ asset: Asset) {
        assertNotMainThread()
        lock.lock()
        defer { lock.unlock() }
        cache.setObject(asset.image, forKey: NSString(string: asset.id))
    }

    func fetchImage(for id: String) -> UIImage? {
        assertNotMainThread()
        lock.lock(); defer { lock.unlock() }
        return cache.object(forKey: NSString(string: id))
    }

    func removeImage(for id: String) {
        assertNotMainThread()
        lock.lock()
        defer { lock.unlock() }
        cache.removeObject(forKey: NSString(string: id))
    }

    private func assertNotMainThread() {
        assert(!Thread.isMainThread, "Calling cache on main thread is not supported.")
    }
}
