import Foundation

enum BundledScript {

    static func source(for script: StikJIT.Script) throws -> String {
        if case .custom(let url) = script {
            guard url.isFileURL else {
                throw StikJITError.customScript("expected a file URL")
            }
            do {
                let source = try String(contentsOf: url, encoding: .utf8)
                guard !source.isEmpty else {
                    throw StikJITError.customScript("the file at \(url.path) is empty")
                }
                return source
            } catch let error as StikJITError {
                throw error
            } catch {
                throw StikJITError.customScript("could not read \(url.path): \(error.localizedDescription)")
            }
        }

        let bundle = Bundle(for: BundleToken.self)
        #if os(tvOS)
        // APPLE TV: resources live in the framework's own bundle. If the
        // upstream convention (bundle-id com.stik.StikJIT) is not what got
        // built, also probe the framework bundle explicitly so a tvOS host
        // that embeds StikJITTV.framework finds universal.js/legacy.js.
        var foundURL: URL?
        if let url = bundle.url(forResource: script.name, withExtension: "js") {
            foundURL = url
        } else if let frameworkURL = Bundle(identifier: "com.stik.StikJITTV")?
            .url(forResource: script.name, withExtension: "js") {
            foundURL = frameworkURL
        }
        guard let url = foundURL,
              let source = try? String(contentsOf: url, encoding: .utf8),
              !source.isEmpty else {
            throw StikJITError.scriptUnavailable
        }
        return source
        #else
        guard let url = bundle.url(forResource: script.name, withExtension: "js"),
              let source = try? String(contentsOf: url, encoding: .utf8),
              !source.isEmpty else {
            throw StikJITError.scriptUnavailable
        }
        return source
        #endif
    }
}

private final class BundleToken {}
