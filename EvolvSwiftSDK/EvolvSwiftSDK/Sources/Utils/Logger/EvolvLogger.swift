//
//  Logger.swift
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

public struct EvolvLogger {
  public static var main: EvolvLogger {
    get {
      guard let _main = _main else {
        preconditionFailure("Logger.main not defined, please define a main logger before using it.")
      }

      return _main
    }

    set {
      _main = newValue
    }
  }

  private static var _main: EvolvLogger?

  public let system: String
  public let destinations: [LogOutput]
  public let formatter: Formatter

  public enum Level: String, Encodable {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
  }

  public init(
    system: String,
    destinations: [LogOutput],
    formatter: Formatter = .default
  ) {
    self.system = system
    self.destinations = destinations
    self.formatter = formatter
  }
}

extension EvolvLogger {
  public func log(
    level: Level,
    msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: Any? = nil
  ) {
    let message = LogMessage(
      date: Date(),
      level: level,
      msg: msg(),
      function: function,
      file: file,
      line: line,
      context: context,
      system: system
    )

    destinations.forEach {
      $0.send(message)
    }
  }

  public func verbose(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: Any? = nil
  ) {
    log(level: .verbose, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func debug(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: Any? = nil
  ) {
    log(level: .debug, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func info(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: Any? = nil
  ) {
    log(level: .info, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func warning(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: Any? = nil
  ) {
    log(level: .warning, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func error(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: Any? = nil
  ) {
    log(level: .error, msg: msg(), function: function, file: file, line: line, context: context)
  }
}
