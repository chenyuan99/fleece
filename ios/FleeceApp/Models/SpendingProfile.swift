import Foundation

struct SpendingProfile: Codable {
    var diningMonthly:    Double = 0
    var groceriesMonthly: Double = 0
    var travelMonthly:    Double = 0
    var gasMonthly:       Double = 0
    var otherMonthly:     Double = 0

    private static let key = "fleeceSpendingProfile"

    static func load() -> SpendingProfile {
        guard let data = UserDefaults.standard.data(forKey: key),
              let p = try? JSONDecoder().decode(SpendingProfile.self, from: data)
        else { return SpendingProfile() }
        return p
    }

    func save() {
        UserDefaults.standard.set(try? JSONEncoder().encode(self), forKey: Self.key)
    }

    var isEmpty: Bool {
        diningMonthly == 0 && groceriesMonthly == 0 &&
        travelMonthly == 0 && gasMonthly == 0 && otherMonthly == 0
    }

    var summary: String {
        [(diningMonthly, "dining"), (groceriesMonthly, "groceries"),
         (travelMonthly, "travel"), (gasMonthly, "gas"), (otherMonthly, "other")]
            .filter { $0.0 > 0 }
            .map { "$\(Int($0.0))/mo \($0.1)" }
            .joined(separator: ", ")
    }
}
