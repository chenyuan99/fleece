import Foundation

// Offline knowledge base encoding data from kb/ directory.
// All query methods accept case-insensitive partial names and return
// pre-formatted strings ready for tool responses in a LanguageModelSession.
enum KnowledgeBase {

    // MARK: - Transfer Partners

    private struct Partner {
        let name: String
        let ratio: String
        let time: String
        let note: String?
        init(_ name: String, _ ratio: String, _ time: String, note: String? = nil) {
            self.name = name; self.ratio = ratio; self.time = time; self.note = note
        }
    }

    private static let airlinePartners: [String: [Partner]] = [
        "chase ur": [
            Partner("Air Canada Aeroplan",          "1:1", "Instant",   note: "Star Alliance; great for United/Lufthansa partner awards"),
            Partner("Air France/KLM Flying Blue",   "1:1", "Instant",   note: "Frequent Promo Rewards discounts 25–50%"),
            Partner("Aer Lingus AerClub",           "1:1", "Instant",   note: "Oneworld Avios, pools with BA/Iberia"),
            Partner("British Airways Avios",        "1:1", "Instant",   note: "Oneworld; short-haul and AA codeshares"),
            Partner("Emirates Skywards",             "1:1", "1–2 days", note: "Emirates metal only"),
            Partner("Iberia Plus",                  "1:1", "Instant",   note: "Cheapest transatlantic on Iberia metal"),
            Partner("Singapore KrisFlyer",          "1:1", "1–2 days", note: "Top-tier for Singapore Suites and partners"),
            Partner("Southwest Rapid Rewards",      "1:1", "Instant",   note: "No partner awards; best for Companion Pass"),
            Partner("United MileagePlus",           "1:1", "Instant",   note: "Star Alliance; strong close-in saver availability"),
            Partner("Virgin Atlantic Flying Club",  "1:1", "Instant",   note: "Best use: ANA business class and Delta One"),
        ],
        "amex mr": [
            Partner("Air Canada Aeroplan",          "1:1", "2–5 days"),
            Partner("Air France/KLM Flying Blue",   "1:1", "Instant",   note: "Frequent transfer bonuses 15–40%"),
            Partner("ANA Mileage Club",             "1:1", "2–5 days", note: "Best for Japan and round-the-world business class"),
            Partner("British Airways Avios",        "1:1", "Instant"),
            Partner("Cathay Pacific Asia Miles",    "1:1", "2–5 days", note: "Oneworld; excellent premium cabin on Cathay metal"),
            Partner("Delta SkyMiles",               "1:1", "Instant",   note: "Dynamic pricing; rarely the best use of MR"),
            Partner("Emirates Skywards",             "1:1", "2–5 days"),
            Partner("Etihad Guest",                 "1:1", "2–5 days", note: "Oneworld partner access"),
            Partner("Hawaiian Miles",               "1:1", "2–5 days"),
            Partner("Iberia Plus",                  "1:1", "Instant"),
            Partner("JetBlue TrueBlue",             "250:200", "Instant", note: "Below 1:1; generally a poor conversion"),
            Partner("Qantas Frequent Flyer",        "1:1", "2–5 days"),
            Partner("Singapore KrisFlyer",          "1:1", "2–5 days"),
            Partner("Virgin Atlantic Flying Club",  "1:1", "Instant",   note: "Best use: ANA and Delta One"),
        ],
        "capital one": [
            Partner("Air Canada Aeroplan",          "1:1", "1–2 days"),
            Partner("Air France/KLM Flying Blue",   "1:1", "1–2 days"),
            Partner("Avianca LifeMiles",            "1:1", "1–2 days", note: "No fuel surcharges; good Star Alliance coverage"),
            Partner("British Airways Avios",        "1:1", "1–2 days"),
            Partner("Emirates Skywards",             "1:1", "1–2 days"),
            Partner("Etihad Guest",                 "1:1", "1–2 days"),
            Partner("EVA Air Infinity MileageLands","2:1.5", "1–2 days", note: "Below 1:1 ratio"),
            Partner("Finnair Plus",                 "1:1", "1–2 days"),
            Partner("Singapore KrisFlyer",          "1:1", "1–2 days"),
            Partner("Turkish Miles&Smiles",         "1:1", "1–2 days", note: "Low pricing for Star Alliance business class"),
            Partner("Virgin Red",                   "1:1", "1–2 days", note: "Converts to Virgin Atlantic Flying Club"),
        ],
        "citi": [
            Partner("Air France/KLM Flying Blue",   "1:1", "24–48 hrs", note: "Strong program with Promo Rewards"),
            Partner("Avianca LifeMiles",            "1:1", "24–48 hrs", note: "No fuel surcharges"),
            Partner("Cathay Pacific Asia Miles",    "1:1", "24–48 hrs"),
            Partner("Emirates Skywards",             "1:1", "24–48 hrs"),
            Partner("Etihad Guest",                 "1:1", "24–48 hrs"),
            Partner("EVA Air Infinity MileageLands","1:1", "24–48 hrs", note: "Better ratio than Capital One's 2:1.5"),
            Partner("Qantas Frequent Flyer",        "1:1", "24–48 hrs"),
            Partner("Singapore KrisFlyer",          "1:1", "24–48 hrs"),
            Partner("Turkish Miles&Smiles",         "1:1", "24–48 hrs", note: "Best Citi use for Star Alliance business class"),
            Partner("Virgin Atlantic Flying Club",  "1:1", "24–48 hrs"),
        ],
        "bilt": [
            Partner("Air Canada Aeroplan",          "1:1", "Instant"),
            Partner("Air France/KLM Flying Blue",   "1:1", "Instant",   note: "Promo Rewards discounts apply"),
            Partner("Alaska Mileage Plan",          "1:1", "Instant",   note: "Excellent for domestic and Oneworld partner routes"),
            Partner("American AAdvantage",          "1:1", "Instant",   note: "Oneworld; useful for Qantas/Cathay partner awards"),
            Partner("British Airways Avios",        "1:1", "Instant"),
            Partner("Cathay Pacific Asia Miles",    "1:1", "Instant"),
            Partner("Emirates Skywards",             "1:1", "Instant"),
            Partner("Iberia Plus",                  "1:1", "Instant"),
            Partner("Turkish Miles&Smiles",         "1:1", "Instant"),
            Partner("United MileagePlus",           "1:1", "Instant"),
            Partner("Virgin Atlantic Flying Club",  "1:1", "Instant",   note: "ANA and Delta One"),
        ],
    ]

    private static let hotelPartners: [String: [Partner]] = [
        "chase ur": [
            Partner("World of Hyatt",  "1:1", "Instant", note: "Best hotel transfer; ~1.7–2.2 cpp at aspirational properties"),
            Partner("IHG One Rewards", "1:1", "Instant", note: "Best with 4th-night-free benefit"),
            Partner("Marriott Bonvoy", "1:1", "Instant", note: "Generally poor value; avoid unless specific property"),
        ],
        "amex mr": [
            Partner("Choice Privileges", "1:1", "2–5 days", note: "Low aspirational value; niche domestic use"),
            Partner("Hilton Honors",     "1:2", "Instant",  note: "Favorable ratio but Hilton points are low value (~0.5 cpp)"),
            Partner("Marriott Bonvoy",   "1:1", "2–5 days", note: "Poor value; same caution as Chase → Marriott"),
        ],
        "capital one": [
            Partner("Wyndham Rewards", "1:1", "1–2 days", note: "Useful for Vacasa vacation rentals via Wyndham"),
            Partner("Accor Live Limitless", "2:1", "1–2 days", note: "Poor ratio; avoid"),
        ],
        "citi": [
            Partner("Wyndham Rewards", "1:1", "24–48 hrs"),
        ],
        "bilt": [
            Partner("World of Hyatt",  "1:1", "Instant", note: "Same top-tier value as Chase UR → Hyatt; Bilt is the only no-fee card with this partner"),
            Partner("IHG One Rewards", "1:1", "Instant"),
            Partner("Marriott Bonvoy", "1:1", "Instant", note: "Poor value as with other programs"),
            Partner("Hilton Honors",   "1:1", "Instant", note: "1:1 here vs Amex's 1:2 — better ratio"),
        ],
    ]

    static func transferPartners(for program: String) -> String {
        let key = programKey(program)
        let airlines = airlinePartners[key]
        let hotels   = hotelPartners[key]
        guard airlines != nil || hotels != nil else {
            return "Unknown program '\(program)'. Supported: Chase UR, Amex MR, Capital One Miles, Citi ThankYou, Bilt."
        }
        var lines: [String] = ["Transfer partners for \(key.uppercased()):"]
        if let a = airlines {
            lines.append("Airlines:")
            lines += a.map { p in
                var s = "  • \(p.name) (\(p.ratio), \(p.time))"
                if let n = p.note { s += " — \(n)" }
                return s
            }
        }
        if let h = hotels {
            lines.append("Hotels:")
            lines += h.map { p in
                var s = "  • \(p.name) (\(p.ratio), \(p.time))"
                if let n = p.note { s += " — \(n)" }
                return s
            }
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Point Valuations

    private static let valuationText: [String: String] = [
        "chase ur": """
        Chase Ultimate Rewards (UR) valuations:
        Floor: 1.0 cpp (cash back) — never redeem for less
        Portal: 1.25 cpp with Sapphire Preferred; 1.5 cpp with Sapphire Reserve
        Best uses:
          • World of Hyatt: 1.7–2.2 cpp (top pick)
          • Virgin Atlantic → ANA/Delta One: 1.5–2.0 cpp
          • Singapore KrisFlyer: 1.5–2.0 cpp
          • Air Canada Aeroplan: 1.3–1.6 cpp
          • Air France/KLM Flying Blue: 1.3–1.5 cpp (higher during Promo Rewards)
          • United MileagePlus: 1.2–1.5 cpp
          • British Airways Avios: 0.8–1.5 cpp (short-haul great; long-haul with surcharges poor)
        Blended average (travel redeemer): ~1.5–1.8 cpp
        """,
        "amex mr": """
        American Express Membership Rewards (MR) valuations:
        Floor: 0.6 cpp (statement credit) — never redeem this way
        Portal: 1.0 cpp via Amex Travel — avoid unless no other option
        Best uses:
          • ANA Mileage Club: 1.5–2.2 cpp (Japan/round-the-world business class)
          • Virgin Atlantic → ANA/Delta One: 1.5–2.0 cpp
          • Singapore KrisFlyer: 1.5–2.0 cpp
          • Cathay Pacific Asia Miles: 1.4–1.8 cpp
          • Air France/KLM Flying Blue: 1.3–1.7 cpp (transfer bonuses push higher)
          • Avianca LifeMiles: 1.3–1.6 cpp
          • Delta SkyMiles: 0.9–1.2 cpp (dynamic pricing; avoid premium cabin)
          • Hilton Honors (1:2 ratio): 0.8–1.0 cpp
        Blended average (travel redeemer): ~1.3–1.8 cpp
        """,
        "capital one": """
        Capital One Miles valuations:
        Floor: 0.5 cpp (statement credit) — avoid
        Portal: 1.0 cpp via Capital One Travel (reasonable floor)
        Best uses:
          • Turkish Miles&Smiles: 1.5–2.2 cpp (Star Alliance business class, low mile prices)
          • Virgin Atlantic Flying Club: 1.5–2.0 cpp (ANA/Delta)
          • Avianca LifeMiles: 1.3–1.6 cpp
          • Singapore KrisFlyer: 1.4–1.8 cpp
          • Air France/KLM Flying Blue: 1.3–1.5 cpp
          • EVA Air (2:1.5 ratio): effectively below 1:1; niche use only
        Blended average (travel redeemer): ~1.2–1.6 cpp
        """,
        "citi": """
        Citi ThankYou Points valuations:
        Floor: 0.5–1.0 cpp (cash/statement credit) — avoid
        Portal: 1.0 cpp via Citi Travel
        Best uses:
          • Turkish Miles&Smiles: 1.5–2.2 cpp (best Citi use; Star Alliance business class)
          • Virgin Atlantic Flying Club: 1.5–2.0 cpp
          • Singapore KrisFlyer: 1.4–1.8 cpp
          • EVA Air: 1.3–1.6 cpp (Citi transfers at 1:1, better than Capital One's 2:1.5)
          • Air France/KLM Flying Blue: 1.3–1.5 cpp
        Blended average (travel redeemer): ~1.2–1.6 cpp
        """,
        "bilt": """
        Bilt Rewards valuations:
        Floor: 1.0 cpp (rent/statement credit) — better floor than most programs
        Portal: 1.25 cpp via Bilt Travel
        Best uses:
          • World of Hyatt: 1.7–2.2 cpp (only no-fee card with Hyatt as partner)
          • Turkish Miles&Smiles: 1.5–2.2 cpp
          • Virgin Atlantic Flying Club: 1.5–2.0 cpp (ANA/Delta)
          • Alaska Mileage Plan: 1.4–1.6 cpp (domestic sweet spots)
          • American AAdvantage: 1.2–1.5 cpp
          • Hilton Honors (1:1 ratio): 0.8–1.0 cpp (better ratio than Amex's 1:2)
        Blended average (travel redeemer): ~1.4–1.8 cpp
        Note: Rent Day (1st of each month) doubles all earn rates for 24 hours.
        """,
    ]

    static func pointValuations(for program: String) -> String {
        let key = programKey(program)
        return valuationText[key] ?? "Unknown program '\(program)'. Supported: Chase UR, Amex MR, Capital One Miles, Citi ThankYou, Bilt."
    }

    // MARK: - Application Rules

    private static let rulesText: [String: String] = [
        "chase": """
        Chase application rules:
        5/24 Rule: Chase denies most cards if you've opened 5+ new credit cards (any issuer) in the past 24 months.
          • Counts: all personal cards from any issuer that appear on your personal credit report
          • Does NOT count: most business cards (Amex, Citi, Chase Ink, Capital One Spark) — don't appear on personal report
          • Does NOT count: authorized user additions (generally)
        Sapphire cooldown: Cannot receive a Sapphire welcome bonus if you received one on any Sapphire card in the past 48 months. Cannot hold both Sapphire Preferred and Sapphire Reserve simultaneously.
        Ink cooldown: Each Ink product has its own 24-month cooldown clock from last bonus received.
        Velocity: ~2 personal cards per 30 days; ~1 business card per 30 days (observed, not published).
        Hard pull bureau: Experian (varies by state).
        """,
        "amex": """
        American Express application rules:
        Once-per-lifetime bonus: Each person can receive the welcome bonus for a given Amex card only once, even after cancelling and reapplying.
        Pop-up warning: Before submitting, Amex may show a "not eligible for welcome offer" pop-up. Proceeding gives approval but no bonus. Pop-up not guaranteed to appear — apply via targeted offer or referral to reduce risk.
        Card limits: Max 5 Amex credit cards simultaneously (charge cards like Platinum/Gold/Green are charge cards with a separate limit).
        Velocity: Amex may decline if you've applied for 4+ Amex cards in 90 days (not published, observed).
        Financial Review: Amex may audit income/spending if unusual activity detected; can result in cancellations.
        Hard pull bureau: Experian (often a soft pull if already a cardholder).
        """,
        "citi": """
        Citi application rules:
        24-month rule (most cards): Cannot receive a bonus if you currently hold the card, closed it within 24 months, or received a bonus on it within 24 months.
        48-month rule (Strata Premier, Prestige): Cooldown is 48 months from when you last received the bonus (not from open/close date).
        Same family: Strata Premier and Prestige are treated as the same family for bonus eligibility.
        Velocity: Max 1 card per 8 days; max 2 cards per 65 days; ~1 personal card per 6 months (observed).
        Hard pull bureau: Equifax or Experian (varies by state).
        """,
        "capital one": """
        Capital One application rules:
        Card limit: Max 2 personal credit cards simultaneously. Business cards are separate.
        Velocity: Typically declines if you opened a Capital One personal card in the past 6 months.
        Triple bureau pull: Capital One pulls all 3 bureaus (Equifax, Experian, TransUnion) for most applications — plan accordingly.
        Bonus cooldown: No published once-per-lifetime rule; generally must close and wait before reapplying for a new bonus (specific window unpublished).
        """,
    ]

    static func applicationRules(for issuer: String) -> String {
        let key = issuer.lowercased()
            .replacingOccurrences(of: "american express", with: "amex")
        let matched = rulesText.keys.first { key.contains($0) || $0.contains(key) }
        guard let k = matched else {
            return "No application rules found for '\(issuer)'. Supported: Chase, Amex, Citi, Capital One."
        }
        return rulesText[k]!
    }

    // MARK: - Card Benefits

    private struct CardBenefitData {
        let lounges: String?
        let tripCancellation: String?
        let tripDelay: String?
        let rentalCar: String?
        let baggage: String?
        let other: String?
    }

    private static let benefits: [(keys: [String], data: CardBenefitData)] = [
        (
            keys: ["sapphire reserve", "csr"],
            data: CardBenefitData(
                lounges: "Chase Sapphire Lounges (BOS, HKG, JFK, LAS, LGA, PHL, PHX, SFO + expanding) + Priority Pass Select (1,400+ lounges worldwide, $35/guest)",
                tripCancellation: "$10,000/person, $20,000/trip",
                tripDelay: "$500/ticket after 6-hour delay or overnight",
                rentalCar: "Primary CDW up to $75,000 — decline rental company's CDW",
                baggage: "Lost/damaged: $3,000/passenger; Delay: $100/day for 5 days after 6 hours",
                other: "Travel accident: up to $1,000,000; Purchase protection: 120 days up to $10,000; Extended warranty: +1 year on warranties ≤ 3 years"
            )
        ),
        (
            keys: ["sapphire preferred", "csp"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: "$10,000/person, $20,000/trip",
                tripDelay: "$500/ticket after 12-hour delay or overnight",
                rentalCar: "Primary CDW",
                baggage: "Lost/damaged: $3,000/passenger; Delay: $100/day for 5 days after 12 hours",
                other: "Travel accident: up to $500,000; Purchase protection: 120 days up to $500; Extended warranty: +1 year on warranties ≤ 3 years"
            )
        ),
        (
            keys: ["amex platinum", "platinum card"],
            data: CardBenefitData(
                lounges: "Centurion Lounges ($50/guest fee unless $75k+ annual spend) + Priority Pass Select + Delta Sky Club (10 visits/year cap unless $75k+ spend) + International Amex Lounges",
                tripCancellation: "$10,000/trip",
                tripDelay: "$500/ticket after 6-hour delay (up to 2 claims per 12 months)",
                rentalCar: "Secondary CDW only (not primary); Premium Car Rental Protection add-on available for ~$25",
                baggage: "Lost: $3,000 carry-on, $2,000 checked (excess over airline reimbursement)",
                other: "Travel accident: up to $500,000; Purchase protection: 90 days up to $10,000; Extended warranty: +1 year on warranties ≤ 5 years"
            )
        ),
        (
            keys: ["amex gold", "gold card"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: "Not included — key gap vs Platinum",
                tripDelay: "$300/ticket after 12-hour delay",
                rentalCar: "Secondary CDW only",
                baggage: "Lost: $1,250 carry-on, $500 checked",
                other: "Purchase protection: 90 days up to $10,000; Extended warranty: +1 year on warranties ≤ 5 years"
            )
        ),
        (
            keys: ["amex green"],
            data: CardBenefitData(
                lounges: "LoungeBuddy credit $100/year (pay-per-visit access at 50+ lounges)",
                tripCancellation: "Not included",
                tripDelay: "Not included",
                rentalCar: "Secondary CDW only",
                baggage: nil,
                other: "CLEAR Plus credit $100/year"
            )
        ),
        (
            keys: ["venture x"],
            data: CardBenefitData(
                lounges: "Capital One Lounges (unlimited, 2 free guests) + Priority Pass Select ($35/guest)",
                tripCancellation: "$2,000/person",
                tripDelay: "$500/ticket after 6 hours",
                rentalCar: "Primary CDW",
                baggage: "Lost: $3,000/passenger",
                other: "Purchase protection: 90 days up to $10,000; Extended warranty: +2 years on warranties ≤ 3 years; Global Entry/TSA PreCheck credit"
            )
        ),
        (
            keys: ["venture", "capital one venture"],
            data: CardBenefitData(
                lounges: "None (Venture only; Venture X has lounge access)",
                tripCancellation: nil,
                tripDelay: nil,
                rentalCar: "Primary CDW",
                baggage: nil,
                other: "Global Entry/TSA PreCheck credit (once every 4 years)"
            )
        ),
        (
            keys: ["bilt"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: "$5,000/trip",
                tripDelay: "$200/day up to $1,800 after 6-hour delay",
                rentalCar: "Primary CDW",
                baggage: nil,
                other: "Cell phone protection: $800/claim, $1,600/year, $25 deductible (pay phone bill with card)"
            )
        ),
        (
            keys: ["freedom unlimited", "cfu"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: nil,
                tripDelay: nil,
                rentalCar: "Primary CDW",
                baggage: nil,
                other: "Purchase protection: 120 days up to $500"
            )
        ),
        (
            keys: ["strata premier", "citi premier"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: "$5,000/trip (when booked with TYP or card)",
                tripDelay: nil,
                rentalCar: nil,
                baggage: nil,
                other: nil
            )
        ),
        (
            keys: ["united club business", "united club"],
            data: CardBenefitData(
                lounges: "Full United Club membership (45+ United hubs) + Star Alliance lounges internationally",
                tripCancellation: "$1,500/trip",
                tripDelay: "$500 after 12 hours",
                rentalCar: nil,
                baggage: nil,
                other: nil
            )
        ),

        // Business cards
        (
            keys: ["sapphire reserve for business"],
            data: CardBenefitData(
                lounges: "Chase Sapphire Lounges + Priority Pass Select ($35/guest)",
                tripCancellation: "$10,000/person, $20,000/trip",
                tripDelay: "$500/ticket after 6 hours",
                rentalCar: "Primary CDW up to $75,000",
                baggage: "Lost: $3,000/passenger; Delay: $100/day after 6 hours",
                other: nil
            )
        ),
        (
            keys: ["ink business preferred", "ink preferred"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: "$5,000/trip",
                tripDelay: "$500 after 12 hours",
                rentalCar: "Primary CDW",
                baggage: nil,
                other: "Cell phone protection: $1,000/claim, $1,800/year, $100 deductible (pay phone bill with card)"
            )
        ),
        (
            keys: ["ink business cash", "ink cash"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: nil,
                tripDelay: nil,
                rentalCar: "Primary CDW",
                baggage: nil,
                other: "Cell phone protection: $1,000/claim, $1,800/year, $100 deductible (pay phone bill with card)"
            )
        ),
        (
            keys: ["ink business unlimited", "ink unlimited"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: nil,
                tripDelay: nil,
                rentalCar: "Primary CDW",
                baggage: nil,
                other: nil
            )
        ),
        (
            keys: ["ink business premier", "ink premier"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: "$5,000/trip",
                tripDelay: "$500 after 12 hours",
                rentalCar: "Primary CDW",
                baggage: nil,
                other: nil
            )
        ),
        (
            keys: ["united business"],
            data: CardBenefitData(
                lounges: "Two single-day United Club passes per year",
                tripCancellation: "$1,500/trip",
                tripDelay: "$500 after 12 hours",
                rentalCar: nil,
                baggage: nil,
                other: nil
            )
        ),
        (
            keys: ["sw premier business", "southwest premier business"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: nil,
                tripDelay: nil,
                rentalCar: nil,
                baggage: nil,
                other: "Earns toward Companion Pass (requires 135,000 qualifying points/calendar year)"
            )
        ),
        (
            keys: ["sw performance business", "southwest performance business"],
            data: CardBenefitData(
                lounges: "4 upgraded boardings/year + Global Entry/TSA PreCheck credit",
                tripCancellation: nil,
                tripDelay: nil,
                rentalCar: nil,
                baggage: nil,
                other: "Earns toward Companion Pass; in-flight Wi-Fi credits (365/year)"
            )
        ),
        (
            keys: ["ihg premier business"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: nil,
                tripDelay: nil,
                rentalCar: nil,
                baggage: nil,
                other: "4th night free on award stays; IHG Platinum Elite status; annual free night certificate"
            )
        ),
        (
            keys: ["hyatt business"],
            data: CardBenefitData(
                lounges: "None",
                tripCancellation: nil,
                tripDelay: nil,
                rentalCar: nil,
                baggage: nil,
                other: "Hyatt Discoverist status; 5 qualifying night credits per year; free night certificate after $15k spend"
            )
        ),
    ]

    static func cardBenefits(for cardName: String) -> String {
        let key = cardName.lowercased()
        // "venture x" must be checked before plain "venture"
        let match = benefits.first { entry in
            entry.keys.contains { k in key.contains(k) || k.contains(key) }
        }
        guard let entry = match else {
            return "No benefits data found for '\(cardName)'. Try the full card name e.g. 'Sapphire Reserve', 'Amex Platinum', 'Venture X'."
        }
        let d = entry.data
        var lines = ["Benefits for \(cardName):"]
        if let v = d.lounges           { lines.append("Lounge access: \(v)") }
        if let v = d.tripCancellation  { lines.append("Trip cancellation: \(v)") }
        if let v = d.tripDelay         { lines.append("Trip delay: \(v)") }
        if let v = d.rentalCar         { lines.append("Rental car: \(v)") }
        if let v = d.baggage           { lines.append("Baggage: \(v)") }
        if let v = d.other             { lines.append("Other: \(v)") }
        return lines.joined(separator: "\n")
    }

    // MARK: - Helpers

    private static func programKey(_ input: String) -> String {
        let s = input.lowercased()
        if s.contains("chase") || s.contains("ur") || s.contains("ultimate") { return "chase ur" }
        if s.contains("amex") || s.contains("membership") || s.contains("mr") { return "amex mr" }
        if s.contains("capital one") || s.contains("c1") { return "capital one" }
        if s.contains("citi") || s.contains("thankyou") || s.contains("typ") { return "citi" }
        if s.contains("bilt") { return "bilt" }
        return s
    }
}
