// This source file is part of the vakoc.com open source project(s)
//
// Copyright © 2017 Mark Vakoc. All rights reserved.
// Licensed under Apache License v2.0
//
// See http://www.vakoc.com/LICENSE.txt for license information


import Foundation


/// Representation of a compilable source file
public struct SourceFile {
    
    /// Create a new source file with the specified contents
    ///
    /// - Parameters:
    ///   - name: The name of the file.  May include path separators
    ///   - contents: The source file content, in utf8
    public init(name: String, contents: Data) {
        self.name = name
        self.contents = contents
    }
    
    /// The name of the source file.  May include relative paths, such as `include/header.h`
    public let name: String
    
    /// The contents in the source file, in UTF-8 encoding
    public let contents: Data
}

/// Detail of a binary produced by a successfull compilation
public struct BinaryInfo {
    
    /// Details of the size of the binary produced during compilation
    public struct Size {
    
        /// The text, or compiled code, segment size
        public let text: Int
    
        /// The data, or initialized variables, segment size
        public let data: Int
        
        /// The bss, or uninitialized variables, segment size
        public let bss: Int
        
        /// The total size, in bytes
        public let size: Int
        
        /// Create the size information from a string
        ///
        /// The incoming string should look like:
        ///
        ///      "   text\t   data\t    bss\t    dec\t    hex\tfilename\n 101312\t   2152\t   9880\t 113344\t  1bac0\t"
        ///
        /// Returns nil if the supplied string could not be parsed
        internal init?(_ string: String) {
            
            let lines = string.components(separatedBy: .newlines)
            if lines.count < 2 {
                return nil
            }
            
            let vals = lines[1].components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            if vals.count < 4 {
                return nil
            }
            
            guard let text = Int(vals[0]), let data = Int(vals[1]), let bss = Int(vals[2]), let size = Int(vals[3]) else { return nil }
            
            self.text = text
            self.data = data
            self.bss = bss
            self.size = size
        }
    }
    
    /// The unique identifier of the binary
    public let binaryId: String
    
    /// The url used to access the binary
    public let binaryUrl: String
    
    /// The expiration date for the binary
    public let expires: Date
    
    /// Information about the size of the binary
    public let sizeInfo: Size
    
}

extension BinaryInfo.Size: Equatable {
    
    public static func ==(lhs: BinaryInfo.Size, rhs: BinaryInfo.Size) -> Bool {
        return lhs.text == rhs.text && lhs.data == rhs.data && lhs.bss == rhs.bss && lhs.size == rhs.size
    }
    
}

extension BinaryInfo.Size: Comparable {
    
    public static func <(lhs: BinaryInfo.Size, rhs: BinaryInfo.Size) -> Bool {
        return lhs.size < rhs.size
    }
}

/// A build issue (error or warning) that happens during compilation
public struct BuildIssue {
    
    /// The type of issue
    ///
    /// - warning: a non-fatal warning
    /// - error: a fatal error that prevents compilation
    public enum IssueType: String {
        case warning
        case error
    }
    /// The issue type
    public var type: IssueType
    
    /// The filename containing the issue
    public var filename: String = ""
    /// The line number of the issue
    public var line: Int = 0
    
    /// The column number of hte issue
    public var column: Int = 0
    
    /// A message describing the issue
    public var message: String = ""
}

extension BuildIssue: CustomStringConvertible {
    public var description: String {
        return "\(filename):\(line):\(column): \(type.rawValue): \(message)"
    }
}

extension BuildIssue: Equatable {
    
    public static func ==(lhs: BuildIssue, rhs: BuildIssue) -> Bool {
        return lhs.type == rhs.type && lhs.filename == rhs.filename && lhs.line == rhs.line && lhs.column == rhs.column && lhs.message == rhs.message
    }
}


/// The result of a compilation web service invocation. 
///
/// A distinction is made between failures.  Any successful invocation of the webservice will result
/// in this enum being returned.  The enum values dictate whether a
///
/// - compileSuccess: A successful compilation.  The associated value is a BinaryInfo structure
/// - compileFailure: The sources failed to compiled.  Associated values include output, stdout, and errors
public enum BuildResult {
    case compileSuccess(BinaryInfo)
    case compileFailure(output: String, stdout: String, errors: [String], issues: [BuildIssue])
}


// MARK: Firmware
extension ParticleCloud {
    

    /// Compile the specified source files for a given device and product.
    ///
    /// Note the completion callback result indicates only whether the web service invocation was successful.
    /// On successful web service invocation the returned BuildResult must be evaluted to determine whether 
    /// the compilation was successful
    ///
    /// - Parameters:
    ///   - files: The files to compile
    ///   - deviceID: The identifier of the device to target
    ///   - product: The product to build for
    ///   - build_target_version: The firmware version to compile against. nil defaults to latest
    ///   - completion: the callback for the asynchronous operation
    public func compile(_ files: [SourceFile], for deviceID: String, product: DeviceInformation.Product, targeting build_target_version: String? = nil, completion: @escaping (Result<BuildResult>) -> Void ) {
        
        self.authenticate(false) { result in
            switch result {
                
            case .failure(let error):
                return completion(.failure(error))
                
            case .success(let accessToken):
                var request = URLRequest(url: self.baseURL.appendingPathComponent("v1/binaries"))
                
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                
                let boundary = UUID().uuidString
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var body = String()
                
                // Insert the product id
                body += "--\(boundary)\r\n"
                body += "Content-Disposition: form-data; name=\"product_id\"\r\n\r\n"
                body += "\(product)\r\n"
                
                if let build_target_version = build_target_version {
                    body += "--\(boundary)\r\n"
                    body += "Content-Disposition: form-data; name=\"build_target_version\"\r\n\r\n"
                    body += "\(build_target_version)\r\n"
                }
                
                for (index,file) in  files.enumerated() {
                    
                    guard let fileContent = String(data: file.contents, encoding: .utf8) else { continue }
                    
                    body += "--\(boundary)\r\n"
                    body += "Content-Disposition: form-data; name=\"file\(index+1)\"; filename=\"\(file.name)\"\r\n\r\n"

                    body += fileContent
                    body += "\r\n"
                }
                body += "--\(boundary)--\r\n"
                
                trace("compile message body:\n\n\(body)\n\n")
                
                request.httpBody = body.data(using: .utf8)
                
                let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                    
                    trace( "Compiled \(files.count) files", request: request, data: data, response: response, error: error)
                    
                    if let error = error {
                        return completion(.failure(ParticleError.createWebhookFailed(error)))
                    }
                    
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any], let j = json {
                        
                        if j.bool(for: "ok") == true {
                            trace("Successfully invoked compilation of \(files.count) file(s) with result \(j)")
                            
                            guard let binary_id = j["binary_id"] as? String,
                                let binary_url = j["binary_url"] as? String,
                                let expires_at = j["expires_at"] as? String,
                                let expires = expires_at.dateWithISO8601String,
                                let size_info = j["sizeInfo"] as? String, let si = BinaryInfo.Size(size_info) else {
                                    
                                    let message = String(data: data, encoding: String.Encoding.utf8) ?? ""
                                    warn("failed to receive expected compile result with response: \(String(describing: response)) and message body \(message)")
                                    return completion(.failure(ParticleError.compileRequestFailed(message)))
                            }
                            
                            let buildResult = BinaryInfo(binaryId: binary_id, binaryUrl: binary_url, expires: expires, sizeInfo: si)
                            completion(.success(.compileSuccess(buildResult)))
                        } else {
                            
                            let errors =  j["errors"] as? [String] ?? []
                            var buildIssues = [BuildIssue]()
                            
                            // ([^:]+):(\d+):(\d+):\s*(\w+):\s*(.*)
                            let regex = "([^:]+):(\\d+):(\\d+):\\s*(\\w+):\\s*(.*)"
                            let exp = try! NSRegularExpression(pattern: regex, options: [])

                            for error in errors {
                                for line in error.components(separatedBy: .newlines) {
                                    let matches = exp.matches(in: line, options: [], range: NSMakeRange(0, line.utf16.count))
                                    
                                    if matches.isEmpty {
                                        
                                        if var issue = buildIssues.last {
                                            issue.message += "\n" + line
                                            buildIssues.removeLast()
                                            buildIssues.append(issue)
                                        }
                                        continue
                                    }
                                    
                                    if let links = matches.flatMap({ result -> (String, Int, Int, BuildIssue.IssueType, String)? in
                                        let r1 = result.rangeAt(1)
                                        let start1 = String.UTF16Index(r1.location)
                                        let end1 = String.UTF16Index(r1.location + r1.length)
                                        let filename = String(line.utf16[start1..<end1])
                                        
                                        let r2 = result.rangeAt(2)
                                        let start2 = String.UTF16Index(r2.location)
                                        let end2 = String.UTF16Index(r2.location + r2.length)
                                        let lineNo = String(line.utf16[start2..<end2])
                                        
                                        let r3 = result.rangeAt(3)
                                        let start3 = String.UTF16Index(r3.location)
                                        let end3 = String.UTF16Index(r3.location + r3.length)
                                        let column = String(line.utf16[start3..<end3])
                                        
                                        
                                        let r4 = result.rangeAt(4)
                                        let start4 = String.UTF16Index(r4.location)
                                        let end4 = String.UTF16Index(r4.location + r4.length)
                                        let kind = String(line.utf16[start4..<end4])
                                        
                                        let r5 = result.rangeAt(5)
                                        let start5 = String.UTF16Index(r5.location)
                                        let end5 = String.UTF16Index(r5.location + r5.length)
                                        let message = String(line.utf16[start5..<end5])
                                        
                                        guard let f = filename, let l1 = lineNo, let l = Int(l1), let c2 = column, let c = Int(c2),let k2 = kind, let k = BuildIssue.IssueType(rawValue: k2), let m = message  else { print("here");  return nil }
                                        
                                        return (f, l, c, k, m)
                                    }).first {
                                        let buildIssue = BuildIssue(type: links.3, filename: links.0, line: links.1, column:links.2 , message: links.4)
                                        buildIssues.append(buildIssue)
                                    }
                                    
                                }
                            }

                            let result: BuildResult = .compileFailure(output: j["output"] as? String ?? "", stdout: j["stdout"] as? String ?? "", errors:errors, issues: buildIssues)
                            completion(.success(result))
                        }
                    } else {
                        
                        let message = data != nil ? String(data: data!, encoding: String.Encoding.utf8) ?? "" : ""
                        warn("failed to compile sources with response: \(String(describing: response)) and message body \(message)")
                        return completion(.failure(ParticleError.compileRequestFailed(message)))
                    }
                }
                task.resume()
            }
        }
    }
}
