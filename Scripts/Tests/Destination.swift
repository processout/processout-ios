#!/usr/bin/env swift

import Foundation

guard let deviceId = try supportedDeviceId() else {
    exit(EXIT_FAILURE)
}

let destination = "platform=iOS Simulator,id=\(deviceId)"
try FileHandle.standardOutput.write(contentsOf: destination)

// MARK: -

func supportedDeviceId(attempt: Int = 0) throws -> String? {
    let devices = try devices()
    let supportedDevices = try runtimes()
        .filter { $0.version.starts(with: "26") && $0.platform == "iOS" }
        .compactMap { devices[$0.identifier] }
        .flatMap { $0 }
        .filter { $0.name.starts(with: "iPhone") && $0.isAvailable }
    // Grab last device to get the most recent iOS version
    if let device = supportedDevices.last {
        return device.udid
    }
    guard attempt < 3 else {
        return nil
    }
    Thread.sleep(forTimeInterval: 3)
    return try supportedDeviceId(attempt: attempt + 1)
}

struct Runtime: Decodable {
    let identifier, version, platform: String
}

func runtimes() throws -> [Runtime] {
    guard let data = try execute(command: "xcrun simctl list runtimes -j") else {
        try? FileHandle.standardError.write(contentsOf: "Unable to retrieve runtimes.")
        return []
    }
    let runtimes = try JSONDecoder().decode([String: [Runtime]].self, from: data)
    return runtimes["runtimes"] ?? []
}

struct Device: Decodable {
    let udid, name: String
    let isAvailable: Bool
}

/// Key is Runtime ID.
func devices() throws -> [String: [Device]] {
    guard let data = try execute(command: "xcrun simctl list devices -j") else {
        try? FileHandle.standardError.write(contentsOf: "Unable to retrieve devices.")
        return [:]
    }
    let devices = try JSONDecoder().decode([String: [String: [Device]]].self, from: data)
    return devices["devices"] ?? [:]
}

func execute(command: String) throws -> Data? {
    let process = Process()
    process.executableURL = URL(filePath: "/bin/bash")
    process.arguments = ["-c", command]
    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    try process.run()
    guard let data = try outputPipe.fileHandleForReading.readToEnd() else {
        return nil
    }
    process.waitUntilExit()
    guard process.terminationReason == .exit else {
        return nil
    }
    return data
}

extension FileHandle {

    func write<T>(contentsOf string: T) throws where T: StringProtocol {
        let data = Data(string.utf8)
        try write(contentsOf: data)
    }
}
