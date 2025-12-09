//
//  AppsFlyerManager.swift
//  ChikyCascade
//

import Foundation
import AppsFlyerLib
import UIKit

final class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {

    // Singleton
    static let shared = AppsFlyerManager()
    
    // MARK: - Properties
    
    private(set) var isOrganic: Bool?
    private(set) var conversionData: [AnyHashable: Any]?
    private var hasReceivedConversionData = false
    
    var onConversionDataReceived: (([AnyHashable: Any]) -> Void)?

    // MARK: - Init

    private override init() {
        super.init()

        let af = AppsFlyerLib.shared()
        af.appsFlyerDevKey = AppConfig.appsFlyerDevKey
        af.appleAppID = AppConfig.appleAppId
        af.delegate = self

        // Включи true на тесте, перед релизом можешь поставить false
        af.isDebug = true
        
        // Ждем 60 секунд для получения данных конверсии
        af.waitForATTUserAuthorization(timeoutInterval: 60)

        af.start()
        
        // Принудительно проверяем данные конверсии через 5 секунд
        // Если AppsFlyer не вызвал делегаты (часто бывает для органических установок)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            
            if !self.hasReceivedConversionData {
                print("🔄 AppsFlyer: No conversion data received after 5s, assuming organic")
                self.isOrganic = true
                self.conversionData = ["af_status": "Organic", "is_first_launch": true]
                self.hasReceivedConversionData = true
                self.onConversionDataReceived?(self.conversionData ?? [:])
            }
        }
    }

    // MARK: - Public API

    /// AppsFlyer ID текущего пользователя (для передачи в Keitaro как utm_placement)
    var appsFlyerId: String {
        AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    /// IDFV (Identifier For Vendor) текущего устройства
    var idfv: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    func buildKeitaroCampaignURL(from baseURLString: String) -> URL? {
        guard var components = URLComponents(string: baseURLString) else {
            return nil
        }

        var queryItems = components.queryItems ?? []

        // Удаляем существующий utm_placement, если вдруг есть, чтобы не дублировать
        queryItems.removeAll { $0.name == "utm_placement" }

        let afId = appsFlyerId
        let subItem = URLQueryItem(name: "utm_placement", value: afId)
        queryItems.append(subItem)

        components.queryItems = queryItems

        print("🔗 Campaign URL: \(components.url?.absoluteString ?? "unknown")")

        return components.url
    }

    // MARK: - AppsFlyerLibDelegate

    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        print("✅ OnConversionDataSuccess: \(installData)")
        
        hasReceivedConversionData = true
        conversionData = installData
        
        // Проверяем органическую установку
        if let afStatus = installData["af_status"] as? String {
            isOrganic = (afStatus == "Organic")
        } else {
            // Если нет данных, считаем органической
            isOrganic = true
        }
        
        print("📊 AppsFlyer: isOrganic = \(isOrganic ?? true)")
        
        // Уведомляем подписчиков
        onConversionDataReceived?(installData)
    }

    func onConversionDataFail(_ error: Error) {
        print("❌ Conversion Data Fail: \(error.localizedDescription)")
        
        hasReceivedConversionData = true
        
        // В случае ошибки считаем органической установкой
        isOrganic = true
        conversionData = ["af_status": "Organic", "error": error.localizedDescription]
        
        // Уведомляем с данными об ошибке
        onConversionDataReceived?(conversionData ?? [:])
    }

    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        print("OnAppOpenAttribution: \(attributionData)")
    }

    func onAppOpenAttributionFailure(_ error: Error) {
        print("OnAppOpenAttributionFailure: \(error.localizedDescription)")
    }
}

