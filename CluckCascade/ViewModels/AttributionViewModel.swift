//
//  AttributionViewModel.swift
//  ChikyCascade
//

import Foundation
import Combine

class AttributionViewModel: ObservableObject {
    @Published var isCheckingAttribution = true
    @Published var shouldShowWebView = false
    @Published var campaignURL: URL?
    
    init() {
        setupAppsFlyerListener()
    }
    
    private func setupAppsFlyerListener() {
        // Инициализируем AppsFlyer
        let afManager = AppsFlyerManager.shared
        
        print("🔧 AttributionViewModel: Setting up AppsFlyer listener")
        print("   - AppsFlyer ID: \(afManager.appsFlyerId)")
        print("   - IDFV: \(afManager.idfv)")
        print("   - Force WebView: \(TestConfig.forceShowWebView)")
        
        // Подписываемся на получение данных конверсии
        afManager.onConversionDataReceived = { [weak self] conversionData in
            print("✅ AttributionViewModel: Conversion data received callback fired!")
            DispatchQueue.main.async {
                self?.handleConversionData(conversionData)
            }
        }
        
        // Таймаут на случай если данные не придут
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            guard let self = self else { return }
            
            if self.isCheckingAttribution {
                print("⏱ AppsFlyer: Timeout - assuming organic install")
                print("   - AppsFlyer ID: \(afManager.appsFlyerId)")
                print("   - IDFV: \(afManager.idfv)")
                self.isCheckingAttribution = false
                self.shouldShowWebView = false
            }
        }
    }
    
    private func handleConversionData(_ conversionData: [AnyHashable: Any]) {
        let afManager = AppsFlyerManager.shared
        
        // Проверяем органическая ли установка
        let isOrganic = afManager.isOrganic ?? true
        
        if TestConfig.verboseLogging {
            print("📱 App Flow Decision:")
            print("   - Is Organic: \(isOrganic)")
            print("   - Conversion Data: \(conversionData)")
            print("   - AppsFlyer ID: \(afManager.appsFlyerId)")
            print("   - IDFV: \(afManager.idfv)")
            print("   - Force WebView: \(TestConfig.forceShowWebView)")
        }
        
        // ТЕСТОВЫЙ РЕЖИМ: принудительно показать WebView
        if TestConfig.forceShowWebView {
            print("   🧪 TEST MODE: Forcing WebView display")
            if let url = afManager.buildKeitaroCampaignURL(from: AppConfig.campaignURL) {
                print("   🔗 Campaign URL: \(url.absoluteString)")
                campaignURL = url
                shouldShowWebView = true
            }
            isCheckingAttribution = false
            return
        }
        
        if isOrganic {
            // Органическая установка - показываем обычное приложение
            print("   ➡️ Showing default app flow (Onboarding or Main)")
            isCheckingAttribution = false
            shouldShowWebView = false
        } else {
            // Неорганическая установка - показываем WebView с кампанией
            print("   ➡️ Showing campaign WebView")
            
            // Строим URL с utm_placement
            if let url = afManager.buildKeitaroCampaignURL(from: AppConfig.campaignURL) {
                print("   🔗 Campaign URL: \(url.absoluteString)")
                campaignURL = url
                shouldShowWebView = true
            } else {
                print("   ⚠️ Failed to build campaign URL, showing default app")
                shouldShowWebView = false
            }
            
            isCheckingAttribution = false
        }
    }
}

