//
//  File.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//


public struct POCardsReponse: Decodable {
    
    public let id: String
    
    public let project_id: String
    
    public let scheme: String
    
    public let co_scheme: String
    
    public let preferred_scheme: String
    
    public let type: String
    
    public let bank_name: String
    
    public let brand: String
    
    public let category: String
    
    public let iin: String
    
    public let last_4_degits: String
    
    public let fingerprint: String
    
    public let exp_month: Int
    
    public let exp_year: Int
    
    public let cvc_check: String
    
    public let avs_check: String
    
    public let token_type: String
    
    public let name: String
    
    public let address1: String
    
    public let address2: String
    
    public let city: String
    
    public let state: String
    
    public let country_code: String
    
    public let zip: String
    
    public let ip_address: String
    
    public let user_agent: String
    
    public let header_accept: String
    
    public let app_color_depth: String
    
    public let app_java_enabled: Bool
    
    public let app_language: String
    
    public let app_screen_height: Int
    
    public let app_screen_width: Int
    
    public let app_timezone_offset: Int
    
    public let expires_soon: Bool
    
    public let metadata: [String: String]
    
    public let sandbox: String
}
