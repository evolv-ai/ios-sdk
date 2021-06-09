//
//  Formatter.swift
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
  public struct Formatter {
    public var format: (EvolvLogger.LogMessage) -> String

    public init(format: @escaping (EvolvLogger.LogMessage) -> String) {
      self.format = format
    }
  }
}

private let dateFormatter = ISO8601DateFormatter()

extension EvolvLogger.Formatter {
  public static let `default` = EvolvLogger.Formatter { msg in
    let dateString = dateFormatter.string(from: msg.date)
    let contextString = msg.context.map { "\($0)" } ?? "<nil>"
    let fileName = msg.file
    return
      "\(dateString) [\(msg.level.rawValue)][\(msg.system)] \(msg.msg) \(fileName).\(msg.function):\(msg.line) | \(contextString)"
  }
}
