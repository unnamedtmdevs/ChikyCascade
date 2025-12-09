//
//  CampaignWebView.swift
//  ChikyCascade
//

import SwiftUI
import WebKit

struct CampaignWebView: View {
    let campaignURL: URL
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            CampaignWebViewController(url: campaignURL)
                .ignoresSafeArea()
        }
    }
}

// MARK: - UIViewController Wrapper
struct CampaignWebViewController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> WebViewController {
        let controller = WebViewController()
        controller.initialURL = url
        return controller
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {}
}

// MARK: - WebViewController
class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @AppStorage("campaign_current_url") var savedURL: String = ""
    
    var initialURL: URL?
    var webView: WKWebView!
    var loadCheckTimer: Timer?
    var isPageLoadedSuccessfully = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        setupWebView()
    }
    
    // MARK: - Keyboard Observers
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // Ничего не делаем - позволяем клавиатуре просто появиться поверх WebView
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // Ничего не делаем - позволяем клавиатуре просто исчезнуть
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - WebView Setup
    private func setupWebView() {
        // Создаем конфигурацию WebView с настройками для обхода детекции
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Отключаем автоматический скролл к полям ввода
        config.suppressesIncrementalRendering = false
        if #available(iOS 13.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        // Создаем WebView с правильной конфигурацией
        webView = WKWebView(frame: .zero, configuration: config)
        
        view.backgroundColor = .black
        view.addSubview(webView)
        
        // ScrollView settings
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.contentInset = .zero
        webView.scrollView.scrollIndicatorInsets = .zero
        
        // Отключаем автоматическое изменение contentInset при появлении клавиатуры
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // Remove space at bottom when scroll down
        if #available(iOS 11.0, *) {
            let insets = view.safeAreaInsets
            webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -insets.bottom, right: 0)
            webView.scrollView.scrollIndicatorInsets = webView.scrollView.contentInset
        }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        // Настройка User-Agent как у реального iPhone Safari
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        loadCookies()
        loadURL()
    }
    
    // MARK: - URL Loading
    private func loadURL() {
        // Проверяем, есть ли сохраненный URL (пользователь уже был на странице)
        let urlString: String
        if !savedURL.isEmpty && savedURL != "about:blank" {
            urlString = savedURL
            print("📱 Loading saved URL: \(urlString)")
        } else if let initial = initialURL {
            urlString = initial.absoluteString
            print("🆕 Loading initial URL: \(urlString)")
        } else {
            print("❌ No URL to load")
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        
        // Добавляем заголовки для обхода anti-bot защиты
        addBrowserHeaders(to: &request)
        
        webView.load(request)
    }
    
    // MARK: - Browser Headers для обхода anti-bot
    private func addBrowserHeaders(to request: inout URLRequest) {
        // Заголовки как у реального Safari на iPhone
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("1", forHTTPHeaderField: "DNT")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("document", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("?1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        // Добавляем Referer если есть предыдущая страница
        if let currentURL = webView?.url {
            request.setValue(currentURL.absoluteString, forHTTPHeaderField: "Referer")
        }
    }
    
    // MARK: - Cookie Management
    private func saveCookies() {
        let cookieJar = HTTPCookieStorage.shared
        
        if let cookies = cookieJar.cookies {
            let data = NSKeyedArchiver.archivedData(withRootObject: cookies)
            UserDefaults.standard.set(data, forKey: "campaign_cookies")
            print("💾 Saved \(cookies.count) cookies")
        }
    }
    
    private func loadCookies() {
        let ud = UserDefaults.standard
        
        if let data = ud.object(forKey: "campaign_cookies") as? Data,
           let cookies = NSKeyedUnarchiver.unarchiveObject(with: data) as? [HTTPCookie] {
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
            print("📥 Loaded \(cookies.count) cookies")
        }
    }
    
    // MARK: - WKUIDelegate
    
    // Отключаем контекстное меню (долгое нажатие)
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        completionHandler(nil)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        
        // Таймер для проверки загрузки страницы (5 секунд)
        loadCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            if let strongSelf = self, !strongSelf.isPageLoadedSuccessfully {
                print("⏱ Страница не загрузилась в течение 5 секунд")
            }
        }
        
        print("🌐 WebView: Started loading \(webView.url?.absoluteString ?? "")")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isPageLoadedSuccessfully = true
        loadCheckTimer?.invalidate()
        
        // Сохраняем текущий URL
        if let currentURL = webView.url?.absoluteString {
            savedURL = currentURL
            print("✅ WebView: Finished loading - saved URL")
        }
        
        // Сохраняем cookies
        saveCookies()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        print("❌ WebView: Failed with error: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        print("❌ WebView: Provisional navigation failed: \(error.localizedDescription)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

