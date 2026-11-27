import Foundation
import Security

enum EndpointValidator {
    static func url(from input: String) throws -> URL {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parts = URLComponents(string: trimmed),
              parts.scheme?.lowercased() == "https",
              let host = parts.host, !host.isEmpty,
              parts.user == nil, parts.password == nil,
              parts.query == nil, parts.fragment == nil,
              let url = parts.url else { throw HealthBridgeError.invalidEndpoint }
        return url
    }
}

enum TokenVault {
    private static let service = "HealthBridge.API"
    private static let account = "bearer"

    private static var base: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service, kSecAttrAccount as String: account]
    }

    private struct Credential: Codable {
        let endpoint: String
        let token: String
    }

    static func save(_ token: String, endpoint: String) throws {
        let value = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.utf8.allSatisfy({ $0 >= 33 && $0 <= 126 }) else {
            throw HealthBridgeError.invalidToken
        }
        if value.isEmpty { try delete(); return }
        let data = try JSONEncoder().encode(Credential(endpoint: endpoint, token: value))
        let result = SecItemUpdate(base as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if result == errSecItemNotFound {
            var item = base
            item[kSecValueData as String] = data
            item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let insert = SecItemAdd(item as CFDictionary, nil)
            guard insert == errSecSuccess else { throw HealthBridgeError.keychainFailure(insert) }
        } else if result != errSecSuccess { throw HealthBridgeError.keychainFailure(result) }
    }

    static func load(endpoint: String) throws -> String {
        var query = base
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return "" }
        guard status == errSecSuccess, let data = result as? Data,
              let credential = try? JSONDecoder().decode(Credential.self, from: data) else { throw HealthBridgeError.keychainFailure(status) }
        return credential.endpoint == endpoint ? credential.token : ""
    }

    static func delete() throws {
        let status = SecItemDelete(base as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw HealthBridgeError.keychainFailure(status) }
    }
}

// Reject redirects, so neither the health payload nor bearer token is forwarded to another destination.
private final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

struct APIClient {
    func send(_ export: HealthExport, endpoint: String, token: String, consent: Bool) async throws -> Int {
        guard consent else { throw HealthBridgeError.missingConsent }
        guard !export.records.isEmpty else { throw HealthBridgeError.noRecords }
        let url = try EndpointValidator.url(from: endpoint)
        let payload = try ExportService.json(export)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(String(export.schemaVersion), forHTTPHeaderField: "X-HealthBridge-Schema")
        let normalizedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if !normalizedToken.isEmpty {
            guard normalizedToken.utf8.allSatisfy({ $0 >= 33 && $0 <= 126 }) else { throw HealthBridgeError.invalidToken }
            request.setValue("Bearer \(normalizedToken)", forHTTPHeaderField: "Authorization")
        }

        let config = URLSessionConfiguration.ephemeral
        config.httpCookieStorage = nil
        config.httpShouldSetCookies = false
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 180
        let session = URLSession(configuration: config, delegate: NoRedirectDelegate(), delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }

        let (_, response) = try await session.upload(for: request, from: payload)
        guard let http = response as? HTTPURLResponse else { throw HealthBridgeError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw HealthBridgeError.httpError(http.statusCode) }
        return http.statusCode
    }
}
