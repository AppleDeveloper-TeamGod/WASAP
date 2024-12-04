//
//  RegexManager.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 12/3/24.
//

import Foundation
import RegexBuilder

extension Regex where Output == (Substring, Substring, Substring) {
    /// ID 관련 키워드 매칭
    public static var idRegex: Regex<RegexOutput> {
        Regex {
            Optionally {
                ChoiceOf {
                    #/\(?[Ww][Ii][-_]?[Ff][Ii]\)?/#
                    #/무선랜/#
                    #/와이파이/#
                    #/FREE|Free|free/#
                    #/무료/#
                }
                #/[:\-._\\/|)\]}\s]*/#
            }
            #/[•\s]*/#
            Capture {
                ChoiceOf {
                    #/\(?[Ss][Ss][Ii][Dd]\)?/#
                    #/\(?[Ii1][I1|\\./∙\s]?[Dd]\)?/#
                    #/아이디/#
                    #/무선랜 이름/#
                    #/명/#
                    #/이름/#
                    #/\(?[Nn][Ee][Tt][Ww][Oo][Rr][Kk]\)?/#
                    #/네트워크/#
                    #/\(?[Ww][Ii1Í]\s?[-_]?\s?[Fft][Ii1Í]\)?/#
                    #/와이파이/#
                }
                NegativeLookahead {
                    #/[-\s]*/#
                    ChoiceOf {
                        #/\(?[Pp][./∙\s]?[Ww]\)?/#
                        #/\(?[Pp][Aa][Ss]{2}[Ww][Oo][Rr][Dd]\)?/#
                        #/\(?[Pp][Aa][Ss]{2}\)?/#
                        #/비밀번호/#
                        #/패스워드/#
                        #/비번/#
                        #/\(?KEY\)?/#
                        #/암호키/#
                        #/암호/#
                        #/Zone|zone|ZONE/#
                    }
                }
            }
            ZeroOrMore(.whitespace)
            Optionally {
                #/[:;\-._\\/|)\]}]/#
            }
            ZeroOrMore(.whitespace)
            Capture {
                ZeroOrMore(.any, .reluctant)
            }
            Optionally {
                ChoiceOf {
                    #/\(?[Pp][./∙\s]?[Ww]\)?/#
                    #/\(?[Pp][Aa][Ss]{2}[Ww][Oo][Rr][Dd]\)?/#
                    #/\(?[Pp][Aa][Ss]{2}\)?/#
                    #/비밀번호/#
                    #/패스워드/#
                    #/비번/#
                    #/\(?KEY\)?/#
                    #/암호키/#
                    #/암호/#
                }
                ZeroOrMore(.any)
            }
        }
    }

    /// PW 관련 키워드 매칭
    public static var pwRegex: Regex<RegexOutput> {
        Regex {
            Optionally {
                ChoiceOf {
                    #/\(?[Ww][Ii][-_]?[Ff][Ii]\)?/#
                    #/무선랜/#
                    #/와이파이/#
                }
                #/[:\-._\\/|)\]}\s]*/#
            }
            ZeroOrMore(.any, .reluctant)
            Capture {
                ChoiceOf {
                    #/\(?[Pp][./∙\s]?[Ww]\)?/#
                    #/\(?[Pp][Aa][Ss]{2}[Ww][Oo][Rr][Dd]\)?/#
                    #/\(?[Pp][Aa][Ss]{2}\)?/#
                    #/비밀번호/#
                    #/패스워드|파스워드/#
                    #/비번/#
                    #/\(?KEY\)?/#
                    #/암호키/#
                    #/암호/#
                }
            }
            ZeroOrMore(.whitespace)
            Optionally {
                #/[:;\-._\\/|)\]}]/#
            }
            ZeroOrMore(.whitespace)
            Capture {
                ZeroOrMore(.any, .reluctant)
            }
            Optionally {
                #/[•\-\s]*/#
            }
        }
    }
}

extension Regex where Output == (Substring, Substring) {
    /// KT 통신사 SSID 매칭
    public static var ktWifiRegex: Regex<RegexOutput> {
        Regex {
            ZeroOrMore(.any, .reluctant)
            Capture {
                "KT"
                #/[\-._\s]*/#
                #/GIGA|GiGA/#
                #/[\-._\s]*/#
                Optionally {
                    #/5G|2G/#
                    #/[\-._\s]*/#
                }
                ZeroOrMore(.any, .reluctant)
            }
            Optionally {
                ChoiceOf {
                    #/\(?[Pp][./∙\s]?[Ww]\)?/#
                    #/\(?[Pp][Aa][Ss]{2}[Ww][Oo][Rr][Dd]\)?/#
                    #/\(?[Pp][Aa][Ss]{2}\)?/#
                    #/비밀번호/#
                    #/패스워드/#
                    #/비번/#
                    #/\(?KEY\)?/#
                    #/암호키/#
                    #/암호/#
                }
                ZeroOrMore(.any)
            }
        }
    }

    /// SKT 통신사 SSID 매칭
    public static var skWifiRegex: Regex<RegexOutput> {
        Regex {
            ZeroOrMore(.any, .reluctant)
            Capture {
                "SK"
                #/[\-._\s]*/#
                #/WIFI|WiFi|Wifi/#
                Optionally {
                    #/GIGA|GiGA/#
                }
                ZeroOrMore(.any)
            }
        }
    }

    /// LG UPlus 통신사 SSID 매칭
    public static var lgWifiRegex: Regex<RegexOutput> {
        Regex {
            ZeroOrMore(.any, .reluctant)
            Capture {
                "U+"
                #/\s*/#
                #/Net|NET|Zone|zone|ZONE/#
                ZeroOrMore(.any)
            }
        }
    }
}

extension Regex where Output == Substring {
    public static var wifiRegex: Regex<RegexOutput> {
        #/\(?[Ww][Ii1Í]\s?[-_]?\s?[Fft][Ii1Í]\)?/#
    }
}
