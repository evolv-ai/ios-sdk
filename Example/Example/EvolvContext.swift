//
//  EvolvContext.swift
//  Example
//
//  Created by Aliaksandr Dvoineu on 15.05.21.
//  Copyright © 2021 Evolv. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let evolvContext = try? newJSONDecoder().decode(EvolvContext.self, from: jsonData)

//
// To read values from URLs:
//
//   let task = URLSession.shared.evolvContextTask(with: url) { evolvContext, response, error in
//     if let evolvContext = evolvContext {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - EvolvContext

let url = "https://participants.evolv.ai/v1/8b50696b6c/C51EEAFC-724D-47F7-B99A-F3494357F164/configuration.json"

struct EvolvContext: Codable {
    let published: Double
    let client: Client
    let experiments: [Experiment]

    enum CodingKeys: String, CodingKey {
        case published = "_published"
        case client = "_client"
        case experiments = "_experiments"
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.clientTask(with: url) { client, response, error in
//     if let client = client {
//       ...
//     }
//   }
//   task.resume()

// MARK: - Client
struct Client: Codable {
    let browser, device, location, platform: String
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.experimentTask(with: url) { experiment, response, error in
//     if let experiment = experiment {
//       ...
//     }
//   }
//   task.resume()

// MARK: - Experiment
struct Experiment: Codable {
    let web: Web
    let predicate: ExperimentPredicate
    let buttonColor, ctaText: ButtonColor?
    let id: String
    let paused: Bool
    let home, next: ButtonColor?

    enum CodingKeys: String, CodingKey {
        case web
        case predicate = "_predicate"
        case buttonColor = "button_color"
        case ctaText = "cta_text"
        case id
        case paused = "_paused"
        case home, next
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.buttonColorTask(with: url) { buttonColor, response, error in
//     if let buttonColor = buttonColor {
//       ...
//     }
//   }
//   task.resume()

// MARK: - ButtonColor
class ButtonColor: Codable {
    let isEntryPoint: Bool
    let predicate: ButtonColorPredicate?
    let values: Bool?
    let initializers: Bool
    let ctaText, layout: ButtonColor?

    enum CodingKeys: String, CodingKey {
        case isEntryPoint = "_is_entry_point"
        case predicate = "_predicate"
        case values = "_values"
        case initializers = "_initializers"
        case ctaText = "cta_text"
        case layout
    }

    init(isEntryPoint: Bool, predicate: ButtonColorPredicate?, values: Bool?, initializers: Bool, ctaText: ButtonColor?, layout: ButtonColor?) {
        self.isEntryPoint = isEntryPoint
        self.predicate = predicate
        self.values = values
        self.initializers = initializers
        self.ctaText = ctaText
        self.layout = layout
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.buttonColorPredicateTask(with: url) { buttonColorPredicate, response, error in
//     if let buttonColorPredicate = buttonColorPredicate {
//       ...
//     }
//   }
//   task.resume()

// MARK: - ButtonColorPredicate
struct ButtonColorPredicate: Codable {
    let combinator: String
    let rules: [Rule]
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.ruleTask(with: url) { rule, response, error in
//     if let rule = rule {
//       ...
//     }
//   }
//   task.resume()

// MARK: - Rule
struct Rule: Codable {
    let field, ruleOperator, value: String

    enum CodingKeys: String, CodingKey {
        case field
        case ruleOperator = "operator"
        case value
    }
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.experimentPredicateTask(with: url) { experimentPredicate, response, error in
//     if let experimentPredicate = experimentPredicate {
//       ...
//     }
//   }
//   task.resume()

// MARK: - ExperimentPredicate
struct ExperimentPredicate: Codable {
    let id: Int?
    let combinator: String?
    let rules: [Rule]?
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.webTask(with: url) { web, response, error in
//     if let web = web {
//       ...
//     }
//   }
//   task.resume()

// MARK: - Web
struct Web: Codable {
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func evolvContextTask(with url: URL, completionHandler: @escaping (EvolvContext?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}

