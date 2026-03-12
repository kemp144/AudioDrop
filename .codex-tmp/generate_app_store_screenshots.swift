import AppKit
import Foundation

struct ShotSpec {
    let sourceName: String
    let outputName: String
    let headline: String
    let subtext: String
    let chips: [String]
    let spotlight: CGRect
    let accentShift: CGFloat
}

extension NSColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
}

let canvasSize = NSSize(width: 1440, height: 900)
let workingDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputDirectory = workingDirectory.appendingPathComponent("Metadata/AppStoreScreenshots", isDirectory: true)

let shots: [ShotSpec] = [
    ShotSpec(
        sourceName: "Screenshot 2026-03-12 at 22.14.32.png",
        outputName: "01-sonicdroplet-overview.png",
        headline: "SonicDroplet",
        subtext: "Record the audio playing on your Mac and save it locally in M4A or WAV.",
        chips: ["System Audio", "Local Save"],
        spotlight: CGRect(x: 0.055, y: 0.225, width: 0.89, height: 0.275),
        accentShift: 0.0
    ),
    ShotSpec(
        sourceName: "Screenshot 2026-03-12 at 22.15.06.png",
        outputName: "02-save-it-your-way.png",
        headline: "Choose Where\nto Save",
        subtext: "Pick a destination right after recording so every file lands exactly where you want it.",
        chips: ["Quick Export", "Local Files"],
        spotlight: CGRect(x: 0.245, y: 0.325, width: 0.69, height: 0.31),
        accentShift: 0.1
    ),
    ShotSpec(
        sourceName: "Screenshot 2026-03-12 at 22.14.38.png",
        outputName: "03-choose-m4a-or-wav.png",
        headline: "Choose M4A or WAV",
        subtext: "Switch between compact exports and lossless audio before you record.",
        chips: ["M4A", "WAV"],
        spotlight: CGRect(x: 0.082, y: 0.605, width: 0.36, height: 0.07),
        accentShift: 0.18
    ),
    ShotSpec(
        sourceName: "Screenshot 2026-03-12 at 22.14.56.png",
        outputName: "04-start-stop-save.png",
        headline: "Start. Stop. Save.",
        subtext: "Clear controls keep every recording session simple, quick, and distraction-free.",
        chips: ["Fast", "Focused"],
        spotlight: CGRect(x: 0.05, y: 0.705, width: 0.90, height: 0.18),
        accentShift: 0.26
    ),
    ShotSpec(
        sourceName: "Screenshot 2026-03-12 at 22.15.13.png",
        outputName: "05-clean-mac-audio-capture.png",
        headline: "Clean Mac Audio Capture",
        subtext: "A polished native recorder for your Mac, with local files ready the moment you finish.",
        chips: ["Native", "Private"],
        spotlight: CGRect(x: 0.055, y: 0.84, width: 0.89, height: 0.13),
        accentShift: 0.34
    )
]

func roundedPath(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func fitRect(for size: NSSize, in bounds: CGRect) -> CGRect {
    let scale = min(bounds.width / size.width, bounds.height / size.height)
    let width = size.width * scale
    let height = size.height * scale
    let x = bounds.minX + (bounds.width - width) * 0.5
    let y = bounds.minY + (bounds.height - height) * 0.5
    return CGRect(x: x, y: y, width: width, height: height)
}

func rectFromTop(x: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
    CGRect(x: x, y: canvasSize.height - top - height, width: width, height: height)
}

func drawShadow(color: NSColor, blur: CGFloat, offset: CGSize = .zero) {
    let shadow = NSShadow()
    shadow.shadowColor = color
    shadow.shadowBlurRadius = blur
    shadow.shadowOffset = offset
    shadow.set()
}

func drawRadialGlow(in rect: CGRect, color: NSColor) {
    let gradient = NSGradient(colors: [
        color.withAlphaComponent(0.32),
        color.withAlphaComponent(0.12),
        color.withAlphaComponent(0.0)
    ])!
    gradient.draw(in: rect, relativeCenterPosition: .zero)
}

func drawBackground(in rect: CGRect, accentShift: CGFloat) {
    let top = NSColor(hex: 0x0A1220)
    let bottom = NSColor(hex: 0x060A12)
    let gradient = NSGradient(starting: top, ending: bottom)!
    gradient.draw(in: rect, angle: -90)

    let primaryAccent = NSColor(hue: 0.58 + accentShift * 0.12, saturation: 0.66, brightness: 0.94, alpha: 1.0)
    let secondaryAccent = NSColor(hue: 0.50 + accentShift * 0.08, saturation: 0.52, brightness: 0.88, alpha: 1.0)

    drawRadialGlow(
        in: CGRect(x: rect.maxX - 420, y: -40, width: 560, height: 560),
        color: primaryAccent
    )
    drawRadialGlow(
        in: CGRect(x: rect.maxX - 620, y: 240, width: 520, height: 520),
        color: secondaryAccent
    )
    drawRadialGlow(
        in: CGRect(x: -140, y: rect.maxY - 260, width: 440, height: 440),
        color: primaryAccent.withAlphaComponent(0.75)
    )

    let wash = NSGradient(colors: [
        NSColor.white.withAlphaComponent(0.08),
        NSColor.white.withAlphaComponent(0.0)
    ])!
    wash.draw(in: CGRect(x: 0, y: 0, width: rect.width, height: 200), angle: -90)

    NSGraphicsContext.saveGraphicsState()
    let linePath = NSBezierPath()
    for offset in stride(from: 110.0, through: rect.width, by: 120.0) {
        linePath.move(to: CGPoint(x: offset, y: 0))
        linePath.line(to: CGPoint(x: offset - 180, y: rect.height))
    }
    linePath.lineWidth = 1
    NSColor.white.withAlphaComponent(0.035).setStroke()
    linePath.stroke()
    NSGraphicsContext.restoreGraphicsState()
}

func drawText(_ text: String, rect: CGRect, font: NSFont, color: NSColor, paragraph: NSMutableParagraphStyle) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph
    ]
    let attributed = NSAttributedString(string: text, attributes: attributes)
    attributed.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading])
}

func drawChip(_ label: String, origin: CGPoint, tint: NSColor) -> CGFloat {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center

    let font = NSFont.systemFont(ofSize: 17, weight: .semibold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white.withAlphaComponent(0.92),
        .paragraphStyle: paragraph
    ]
    let attributed = NSAttributedString(string: label, attributes: attributes)
    let size = attributed.boundingRect(with: NSSize(width: 240, height: 40), options: [.usesLineFragmentOrigin, .usesFontLeading]).size
    let width = ceil(size.width) + 28
    let height: CGFloat = 38
    let rect = CGRect(x: origin.x, y: origin.y, width: width, height: height)

    let fill = NSColor(calibratedWhite: 1.0, alpha: 0.08)
    let stroke = tint.withAlphaComponent(0.28)

    fill.setFill()
    roundedPath(rect, radius: 19).fill()
    stroke.setStroke()
    let path = roundedPath(rect.insetBy(dx: 0.5, dy: 0.5), radius: 18.5)
    path.lineWidth = 1
    path.stroke()

    attributed.draw(with: CGRect(x: rect.minX, y: rect.minY + 8, width: rect.width, height: 24), options: [.usesLineFragmentOrigin, .usesFontLeading])
    return rect.maxX
}

func drawScreenshot(_ image: NSImage, in frame: CGRect, spotlight: CGRect, accent: NSColor, rotation: CGFloat) {
    NSGraphicsContext.saveGraphicsState()
    drawShadow(color: NSColor.black.withAlphaComponent(0.35), blur: 40, offset: CGSize(width: 0, height: 22))
    NSColor.black.withAlphaComponent(0.18).setFill()
    roundedPath(frame, radius: 44).fill()
    NSGraphicsContext.restoreGraphicsState()

    let plateFill = NSColor(calibratedWhite: 1.0, alpha: 0.06)
    let plateStroke = NSColor.white.withAlphaComponent(0.10)
    plateFill.setFill()
    roundedPath(frame, radius: 44).fill()
    plateStroke.setStroke()
    let plateBorder = roundedPath(frame.insetBy(dx: 0.5, dy: 0.5), radius: 43.5)
    plateBorder.lineWidth = 1
    plateBorder.stroke()

    let imageBounds = frame.insetBy(dx: 28, dy: 28)
    let imageRect = fitRect(for: image.size, in: imageBounds)

    let center = CGPoint(x: imageRect.midX, y: imageRect.midY)
    let transform = NSAffineTransform()
    transform.translateX(by: center.x, yBy: center.y)
    transform.rotate(byDegrees: rotation)
    transform.translateX(by: -center.x, yBy: -center.y)

    NSGraphicsContext.saveGraphicsState()
    transform.concat()
    drawShadow(color: NSColor.black.withAlphaComponent(0.45), blur: 34, offset: CGSize(width: 0, height: 24))
    image.draw(in: imageRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    transform.concat()

    let normalizedSpotlight = CGRect(
        x: imageRect.minX + spotlight.minX * imageRect.width,
        y: imageRect.minY + (1.0 - spotlight.minY - spotlight.height) * imageRect.height,
        width: spotlight.width * imageRect.width,
        height: spotlight.height * imageRect.height
    )

    let outerMask = roundedPath(imageRect, radius: 28)
    let innerCutout = roundedPath(normalizedSpotlight.insetBy(dx: -18, dy: -18), radius: 30)
    outerMask.append(innerCutout)
    outerMask.windingRule = .evenOdd
    NSColor.black.withAlphaComponent(0.18).setFill()
    outerMask.fill()

    let glowRect = normalizedSpotlight.insetBy(dx: -72, dy: -72)
    NSGraphicsContext.saveGraphicsState()
    roundedPath(imageRect, radius: 28).addClip()
    drawRadialGlow(in: glowRect, color: accent.withAlphaComponent(0.85))
    NSGraphicsContext.restoreGraphicsState()

    let spotlightPath = roundedPath(normalizedSpotlight, radius: 24)
    accent.withAlphaComponent(0.75).setStroke()
    spotlightPath.lineWidth = 4
    spotlightPath.stroke()

    let sheen = NSGradient(colors: [
        NSColor.white.withAlphaComponent(0.22),
        NSColor.white.withAlphaComponent(0.02)
    ])!
    sheen.draw(in: normalizedSpotlight, angle: -90)

    NSGraphicsContext.restoreGraphicsState()
}

func exportShot(_ spec: ShotSpec, index: Int) throws {
    let sourceURL = workingDirectory.appendingPathComponent(spec.sourceName)
    guard let sourceImage = NSImage(contentsOf: sourceURL) else {
        throw NSError(domain: "ScreenshotGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing screenshot: \(spec.sourceName)"])
    }

    let rect = CGRect(origin: .zero, size: canvasSize)
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width),
        pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "ScreenshotGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create bitmap for \(spec.outputName)"])
    }

    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "ScreenshotGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create graphics context for \(spec.outputName)"])
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.imageInterpolation = .high
    context.shouldAntialias = true
    bitmap.size = canvasSize

    drawBackground(in: rect, accentShift: spec.accentShift)

    let accent = NSColor(hue: 0.58 + spec.accentShift * 0.12, saturation: 0.72, brightness: 0.96, alpha: 1.0)

    let textParagraph = NSMutableParagraphStyle()
    textParagraph.lineBreakMode = .byWordWrapping
    textParagraph.alignment = .left

    let eyebrowParagraph = NSMutableParagraphStyle()
    eyebrowParagraph.alignment = .left

    drawText(
        "macOS audio capture",
        rect: rectFromTop(x: 110, top: 126, width: 320, height: 24),
        font: NSFont.systemFont(ofSize: 18, weight: .semibold),
        color: accent.withAlphaComponent(0.92),
        paragraph: eyebrowParagraph
    )

    drawText(
        spec.headline,
        rect: rectFromTop(x: 110, top: 156, width: 540, height: 210),
        font: NSFont.systemFont(ofSize: 74, weight: .heavy),
        color: NSColor.white.withAlphaComponent(0.98),
        paragraph: textParagraph
    )

    drawText(
        spec.subtext,
        rect: rectFromTop(x: 114, top: 382, width: 470, height: 160),
        font: NSFont.systemFont(ofSize: 28, weight: .regular),
        color: NSColor.white.withAlphaComponent(0.78),
        paragraph: textParagraph
    )

    let lineRect = rectFromTop(x: 114, top: 552, width: 380, height: 1)
    NSColor.white.withAlphaComponent(0.10).setFill()
    NSBezierPath(rect: lineRect).fill()

    var chipX: CGFloat = 114
    for chip in spec.chips {
        chipX = drawChip(chip, origin: CGPoint(x: chipX, y: canvasSize.height - 575 - 38), tint: accent) + 14
    }

    drawText(
        String(format: "0%d", index + 1),
        rect: rectFromTop(x: 114, top: 84, width: 40, height: 32),
        font: NSFont.monospacedDigitSystemFont(ofSize: 19, weight: .semibold),
        color: NSColor.white.withAlphaComponent(0.38),
        paragraph: textParagraph
    )

    drawScreenshot(
        sourceImage,
        in: CGRect(x: 720, y: 54, width: 620, height: 792),
        spotlight: spec.spotlight,
        accent: accent,
        rotation: [-1.8, 1.1, -1.2, 1.6, -0.8][index]
    )

    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "ScreenshotGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to encode PNG for \(spec.outputName)"])
    }

    try pngData.write(to: outputDirectory.appendingPathComponent(spec.outputName))
}

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

for (index, shot) in shots.enumerated() {
    try exportShot(shot, index: index)
    print("Generated \(shot.outputName)")
}
