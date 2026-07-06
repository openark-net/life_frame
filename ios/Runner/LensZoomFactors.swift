import AVFoundation
import Flutter

enum LensZoomFactors {
  private static let channelName = "life_frame/lens_metadata"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getBackLensZoomFactors":
        result(backLensZoomFactors())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func backLensZoomFactors() -> [String: Double] {
    let session = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera],
      mediaType: .video,
      position: .back
    )

    var factors: [String: Double] = [:]
    for virtualDevice in session.devices {
      merge(virtualDevice: virtualDevice, into: &factors)
    }
    return factors
  }

  private static func merge(virtualDevice: AVCaptureDevice, into factors: inout [String: Double]) {
    let constituents = virtualDevice.constituentDevices
    let switchOvers = virtualDevice.virtualDeviceSwitchOverVideoZoomFactors.map {
      CGFloat(truncating: $0)
    }

    guard switchOvers.count == constituents.count - 1,
      switchOvers.allSatisfy({ $0 > 1.0 }),
      zip(switchOvers, switchOvers.dropFirst()).allSatisfy({ $0 < $1 }),
      let wideIndex = constituents.firstIndex(where: {
        $0.deviceType == .builtInWideAngleCamera
      })
    else { return }

    let zoomAtConstituent: [CGFloat] = [1.0] + switchOvers
    let baseline = zoomAtConstituent[wideIndex]

    for (index, constituent) in constituents.enumerated() {
      let displayFactor = Double(zoomAtConstituent[index] / baseline)
      guard isPlausible(displayFactor, for: constituent.deviceType),
        factors[constituent.uniqueID] == nil
      else { continue }
      factors[constituent.uniqueID] = displayFactor
    }
  }

  private static func isPlausible(_ displayFactor: Double, for type: AVCaptureDevice.DeviceType)
    -> Bool
  {
    switch type {
    case .builtInUltraWideCamera:
      return displayFactor > 0.0 && displayFactor < 1.0
    case .builtInWideAngleCamera:
      return displayFactor == 1.0
    case .builtInTelephotoCamera:
      return displayFactor > 1.0
    default:
      return false
    }
  }
}
