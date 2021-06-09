//
//  Destination.swift
//
//  Copyright (c) 2021 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import Foundation

extension EvolvLogger {
  public struct LogOutput {
    public var send: (EvolvLogger.LogMessage) -> Void

    public init(send: @escaping (EvolvLogger.LogMessage) -> Void) {
      self.send = send
    }
  }
}

extension EvolvLogger.LogOutput {
  public static func console(using formatter: EvolvLogger.Formatter = .default) -> EvolvLogger.LogOutput {
    EvolvLogger.LogOutput(
      send: { msg in
        #if DEBUG
          print(formatter.format(msg))
        #endif
      }
    )
  }

  public static func file(atURL url: URL, using formatter: EvolvLogger.Formatter = .default) throws
    -> EvolvLogger.LogOutput
  {
    let queue = DispatchQueue(label: "br.dev.native.logger.filedestination")

    if !FileManager.default.fileExists(atPath: url.path) {
      // TODO: maybe pass in some attributes?
      FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    }

    return EvolvLogger.LogOutput { msg in
      queue.sync {
        do {
          let handle = try FileHandle(forWritingTo: url)
          handle.seekToEndOfFile()
//          handle.write(Data("\(formatter.format(msg))\n".utf8))
          handle.closeFile()
        } catch {
          print(error)
        }
      }
    }
  }
}
