//
//  POCardTokenizationResponse.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation


public struct POCardTokenizationResponse: Decodable {
    
    let card: POCard
    
    struct POCard: Decodable {
        
        /// Value that uniquely identifies the card
        public let id: String
        
        /// Project that the card belongs to
        public let project_id: String
        
        /// Scheme of the card, such as Visa or Mastercard
        public let scheme: String
        
        /// Co-scheme of the card, such as Carte Bancaire
        public let co_scheme: String?
        
        /// Preferred scheme defined by the Customer
        public let preferred_scheme: String?
        
        /// Card type (debit or credit)
        public let type: String
        
        /// Name of the card’s issuing bank
        public let bank_name: String
        
        /// Brand of the card, such as Electron, Classic or Gold
        public let brand: String
        
        /// Card category (consumer or commercial)
        public let category: String
        
        /// Issuer identification number. Corresponds to the first 6 or 8 digits of the main card number.
        public let iin: String
        
        /// Last 4 digits of the card
        public let last_4_degits: String
        
        /// Hash value that remains the same for this card even if it is tokenized several times
        public let fingerprint: String
        
        /// Month of the expiration date
        public let exp_month: Int
        
        /// Year of the expiration date
        public let exp_year: Int
        
        /// CVC check status
        public let cvc_check: String
        
        /// AVS check status
        public let avs_check: String
        
        /// Contains the name of a third party tokenization method
        public let token_type: String?
        
        /// Cardholder’s name
        public let name: String
        
        /// First line of cardholder’s address
        public let address1: String?
        
        /// Second line of cardholder’s address
        public let address2: String?
        
        /// City of cardholder’s address
        public let city: String?
        
        /// State or county of cardholder’s address
        public let state: String?
        
        /// Country code of cardholder’s address
        public let country_code: String
        
        /// ZIP code of cardholder’s address
        public let zip: String
        
        /// IP address of the cardholder
        public let ip_address: String
        
        /// Value of the User-Agent header of the cardholder
        public let user_agent: String?
        
        /// Value of the Accept header of the cardholder
        public let header_accept: String?
        
        /// Supported color depth on the cardholder’s screen, if one is available
        public let app_color_depth: String?
        
        /// Denotes whether or not Java is enabled on the cardholder device
        public let app_java_enabled: Bool?
        
        /// Language of the cardholder’s device, if available
        public let app_language: String?
        
        /// Height in pixels of the cardholder’s screen
        public let app_screen_height: Int?
        
        /// Width in pixels of the cardholder’s screen
        public let app_screen_width: Int?
        
        /// Timezone offset of the cardholder
        public let app_timezone_offset: Int
        
        /// Set to true if the card will expire soon, otherwise false
        public let expires_soon: Bool
        
        /// Metadata related to the card, in the form of key-value pairs
        public let metadata: [String: String]
        
        /// Denotes whether or not this card was created in the sandbox testing environment
        public let sandbox: String
        
        /// Date and time when this card was created
        public let created_at: Date
        
        /// Type of card update
        public let update_type: String?
    }
}
