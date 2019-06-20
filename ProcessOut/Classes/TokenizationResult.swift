//
//  TokenizationResult.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/06/2019.
//

class TokenizationResult: ApiResponse {
    
    class Card: Decodable {
        var id: String
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
        }
    }

    var card: Card?
    
    private enum CodingKeys: String, CodingKey {
        case card = "card"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.card = try container.decode(Card.self, forKey: .card)
        try super.init(from: decoder)
    }
}
