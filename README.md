# WPKit

This was originally planned as an open source API for the german anti-fake-news-collective (volksverpetzer)[https://www.volksverpetzer.de] (yes it is really against fake-news and does studies and proofs and stuff like that, the translation is like "people's tattletale").

## Disclaimer

This is solely a free-time project of my own, [https://volksverpetzer.de](volksverpetzer) and their respective representatives have nothing to do with it. The only thing they are responsible for is the content of the articles shown.
This, in return, means that I am not responsible for any content, only for _how_. 
It simply exists because the founder of the collective suggested to implement an app (as a possible project for them, again, I am simply doing this because I want, not them).
For more information, please have a look at the LICENSE.

## Targets

- Create an API to communicate with the website
    - get posts
    - post posts (authed only)
    - delete posts (authed only)
- Create an app to interact with the API (an extra repo will follow)
    - prototyped in SwiftUI, full version in UIKit as I want to make it reachable for as many (for now Apple only) users as possible
    - subtarget is to not only provide the current posts but also to keep in mind to structure by categories, tags, authors and so on to be able to create a database. 
    - similiarly, I might also make the data more accessible for bulk data analysis, reference management and so on
    
    
Targets marked "(authed only)" are not reachable for now because I need an auth key access the required endpoints. I'll contact the collective as soon as I have something to present.

## Off-topic

Although this kit was originally planned for use with [https://www.volksverpetzer.de](volksverpetzer), it can also be used with any other wordpress site using wordpress 5.4 and above (?).
You can check if this package is working for your website by editing `Tests/VolksverpetzerKitTests/testOptions.swift` to your needs. 
