import SwiftUI
import PhotosUI
import UIKit

struct PhotoInput: View {
    let onImage: (Data) -> Void
    @State private var selection: PhotosPickerItem?
    @State private var camera = false
    @State private var error: String?
    var body: some View {
        HStack {
            PhotosPicker(selection: $selection, matching: .images) { Label("Photo library", systemImage: "photo.on.rectangle") }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button { camera = true } label: { Label("Camera", systemImage: "camera") }
            }
        }
        .onChange(of: selection) { _, value in
            Task {
                do {
                    guard let value, let data = try await value.loadTransferable(type: Data.self), let image = UIImage(data: data), let normalized = image.jpegData(compressionQuality: 0.85) else { error = "Could not open this photo."; return }
                    onImage(normalized); selection = nil
                } catch { self.error = "Could not open this photo. Please try again." }
            }
        }
        .sheet(isPresented: $camera) { CameraPicker { image in if let data = image.jpegData(compressionQuality: 0.85) { onImage(data) } } }
        .alert("Photo unavailable", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) { Button("OK") { error = nil } } message: { Text(error ?? "") }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onImage: (UIImage) -> Void
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController(); picker.sourceType = .camera; picker.delegate = context.coordinator; return picker
    }
    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { parent.onImage(image) }; parent.dismiss()
        }
    }
}

struct PhotoThumbnail: View {
    let data: Data?
    var body: some View {
        Group { if let data, let image = UIImage(data: data) { Image(uiImage: image).resizable().scaledToFill() } else { Image(systemName: "tshirt").foregroundStyle(.secondary) } }
            .frame(width: 58, height: 70).clipped().background(.quaternary).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
