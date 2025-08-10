import Foundation

struct RateFetcher {
    enum FetchError: Error { case badData }

    private struct HostResponse: Decodable { let rates: [String: Double] }
    private struct ERAPIResponse: Decodable { let rates: [String: Double] }

    static func fetch(base: String = "AUD", quote: String = "NPR") async throws -> Double {
        if let v = try? await fetchFromHost(base: base, quote: quote) { return v }
        if let v = try? await fetchFromERAPI(base: base, quote: quote) { return v }
        throw FetchError.badData
    }

    private static func fetchFromHost(base: String, quote: String) async throws -> Double? {
        let url = URL(string: "https://api.exchangerate.host/latest?base=\(base)&symbols=\(quote)")!
        var req = URLRequest(url: url)
        req.cachePolicy = .reloadIgnoringLocalCacheData
        req.timeoutInterval = 8
        let (data, response) = try await URLSession.shared.data(for: req)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
        let decoded = try JSONDecoder().decode(HostResponse.self, from: data)
        return decoded.rates[quote]
    }

    private static func fetchFromERAPI(base: String, quote: String) async throws -> Double? {
        let url = URL(string: "https://open.er-api.com/v6/latest/\(base)")!
        var req = URLRequest(url: url)
        req.cachePolicy = .reloadIgnoringLocalCacheData
        req.timeoutInterval = 8
        let (data, response) = try await URLSession.shared.data(for: req)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
        let decoded = try JSONDecoder().decode(ERAPIResponse.self, from: data)
        return decoded.rates[quote]
    }
}
