//
//  WebView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/8/24.
//

/// https://sarunw.com/posts/swiftui-webview/

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView { // required method from UIViewRepresentable
        // return the UIView that we want to bridge from the method (WKWebView)
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) { // required method from UIViewRepresentable
        // called when there is a state change (we load a new URL)
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
