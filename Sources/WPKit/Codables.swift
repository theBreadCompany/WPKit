//
//  Codables.swift
//
//
//  Created by Fabio Mauersberger on 18.08.22.
//

import Foundation

/**
 This is the identity of every post.
 
 For now, none of the properties can be left out,
 only these non-implemented ones: yoast_head and yoast_head_json.
 
 These two keys will, for now, stay unimplemented as they are practically
 never used.
 */
public struct WPPost: Codable {
    
    public enum Status: String, Codable, Hashable {
        case publish
    }
    
    public enum PostType: String, Codable, Hashable {
        case post, open, closed
    }
    
    private struct GUID: Codable, Hashable {
        public var rendered: URL
    }
    
    public struct Content: Codable, Hashable {
        public var rendered: String
        public var protected: Bool?
    }
    
    public typealias Title = Content
    public typealias Excerpt = Content
    public typealias Caption = Content
    
    public enum CommentStatus: String, Codable {
        case closed, open
    }
    
    typealias PingStatus = PostType
    
    public enum Format: String, Codable {
        case standard, aside, chat, gallery, link,
             image, quote, status, video, audio
    }
    
    public struct Meta: Codable {
        public var _et_pb_use_builder: String
        public var _et_pb_old_content: String
        public var _et_gb_content_width: String
    }
    
    /// Basically a placeholder type that can store everything around an href.
    /// The information contained here is not really used for now and not even accessible,
    /// but that will follow
    struct _Link: Codable, Hashable {
        var href: URL
        var embeddable: Bool?
        var count: Int?
        var id: Int?
        var taxonomy: String?
        var templated: Bool?
        
    }
    
    // A lot of boilerplate :/
    // Also, the 'curies' property is missing.
    public struct Links: Codable, Hashable {
        
        enum CodingKeys: String, CodingKey {
            case _self = "self"
            case _collection = "collection"
            case _about = "about"
            case _author = "author"
            case _replies = "replies"
            case _version_history = "version-history"
            case _predecessor_version = "predecessor-version"
            case _wp_featuredmedia = "wp:featuredmedia"
            case _wp_attachment = "wp:attachment"
            case _wp_term = "wp:term"
        }
        
        var _self: Array<_Link>
        var _collection: Array<_Link>
        var _about: Array<_Link>
        var _author: Array<_Link>
        var _replies: Array<_Link>
        var _version_history: Array<_Link>
        var _predecessor_version: Array<_Link>
        var _wp_featuredmedia: Array<_Link>
        var _wp_attachment: Array<_Link>
        var _wp_term: Array<_Link>
        
        
        public var `self`: URL { _self.first!.href }
        public var collection: URL { _collection.first!.href }
        public var about: URL { _about.first!.href }
        public var author: URL { _author.first!.href }
        public var replies: URL { _replies.first!.href }
        public var version_history: URL { _version_history.first!.href }
        public var predecessor_version: URL { _predecessor_version.first!.href }
        public var wp_featuredmedia: URL { _wp_featuredmedia.first!.href }
        public var wp_attachment: URL { _wp_attachment.first!.href }
        public var wp_term: [URL] { _wp_term.map({$0.href}) }
    }
    
    // wp:term wip for now because wtf
    public struct EmbeddedInfo: Codable, Hashable {
        enum CodingKeys: String, CodingKey {
            case author
            case wp_featuredmedia = "wp:featuredmedia"
            case _wp_term = "wp:term"
        }
        
        public struct FeaturedMedia: Codable, Hashable {
            public enum FeaturedType: String, Codable { case attachment }
            public enum MediaType: String, Codable { case image }
            
            public struct MediaDetails: Codable, Hashable {
                
                public struct MediaSizes: Codable, Hashable {
                    
                    public struct Size: Codable, Hashable {
                        public var file: String
                        public var width: Int
                        public var height: Int
                        public var mime_type: String
                        public var source_url: URL
                    }
                    
                    public var medium: Size
                    public var large: Size
                    public var thumbnail: Size
                    public var medium_large: Size
                    public var fiat_thumb: Size
                    public var cmplz_banner_image: Size?
                    public var full: Size
                    
                }
                
                // PITA to transfer to a [CG/NS]Image and basically only relevant for creators, proofers and databases
                public struct MediaMetadata: Codable, Hashable {
                    public var aperture: String
                    public var credit: String
                    public var camera: String
                    public var caption: String
                    public var created_timestamp: String
                    public var copyright: String
                    public var focal_length: String
                    public var iso: String
                    public var shutter_speed: String
                    public var title: String
                    public var orientation: String
                    public var keywords: Array<String>
                }
                
                public var width: Int
                public var height: Int
                public var file: String // relative to https://example.com/wp-content/uploads
                public var sizes: MediaSizes
                public var image_meta: MediaMetadata
            }
            
            public var id: Int?
            public var date: Date?
            public var type: FeaturedType?
            public var slug: String?
            public var link: URL?
            public var title: WPPost.Title?
            public var author: Int?
            public var caption: WPPost.Caption?
            public var alt_text: String?
            public var media_type: String?
            public var mime_type: String?
            public var media_details: MediaDetails?
            public var source_url: URL?
        }
        
        public struct Term: Codable, Hashable {
            
            public enum Taxonomy: String, Codable {
                case category, post_tag
            }
            
            public var id: Int
            public var link: URL
            public var name: String
            public var slug: String
            public var taxonomy: Taxonomy
        }
        
        public var author: Array<WPUser>
        public var wp_featuredmedia: [FeaturedMedia]
        private var _wp_term: [[Term]]
        // convenience
        public var wp_term: [Term] {
            _wp_term.flatMap({$0})
        }
    }
    
    public var id: Int
    public var date: Date?
    public var date_gmt: Date?
    private var guid: GUID
    public var modified: Date?
    public var modified_gmt: Date
    public var slug: String?
    public var status: Status?
    public var type: PostType?
    public var link: URL?
    public var title: Title?
    public var content: Content?
    public var excerpt: Excerpt?
    public var author: Int?
    public var featured_media: Int?
    public var comment_status: CommentStatus?
    private var ping_status: PingStatus?
    public var sticky: Bool?
    public var template: String?
    public var format: Format?
    public var categories: [Int]?
    public var tags: [Int]?
    public var _links: Links? // ignore for now because only relevant for web devs
    public var _embedded: EmbeddedInfo?
    
    public enum Property: String, CaseIterable {
        case id, date, date_gmt, guid, modified, modified_gmt, slug, status, type, link, title, content, excerpt, author, featured_media, comment_status, ping_status, sticky, template, format, categories, tags, _links, _embedded
    }
    
    public var availableProperties: [Property] {
        Mirror(reflecting: self).children.compactMap({Property(rawValue: $0.label ?? "")})
        
    }
}

public struct WPUser: Codable {
    
    struct Links: Codable {
        enum CodingKeys: String, CodingKey {
            case _self = "self"
            case _collection = "collection"
        }
        
        var _self: Array<WPPost._Link>
        var _collection: Array<WPPost._Link>
        
        public var `self`: URL { _self.first!.href }
        public var collection: URL { _collection.first!.href }
        
    }
    
    public var id: Int
    public var name: String
    public var url: String
    public var description: String
    public var link: URL
    public var slug: String
}

extension WPPost: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
extension WPUser: Hashable {}
