import Foundation

// MARK: - Language

enum Language: String, CaseIterable {
    case english = "en"
    case turkish = "tr"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case japanese = "ja"
    case chinese = "zh"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .spanish: return "Español"
        case .japanese: return "日本語"
        case .chinese: return "中文"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .turkish: return "🇹🇷"
        case .german: return "🇩🇪"
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        case .japanese: return "🇯🇵"
        case .chinese: return "🇨🇳"
        }
    }
}

// MARK: - Localization

struct L10n {
    static var current: Language {
        get {
            if let code = UserDefaults.standard.string(forKey: "appLanguage"),
               let lang = Language(rawValue: code) {
                return lang
            }
            // Auto-detect from system
            let systemLang: String
            if #available(macOS 13, *) {
                systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            } else {
                systemLang = Locale.current.languageCode ?? "en"
            }
            return Language(rawValue: systemLang) ?? .english
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }

    // MARK: - App General
    static var appName: String { "DodoNest" }
    static var language: String { tr("Language", "Dil", "Sprache", "Langue", "Idioma", "言語", "语言") }
    static var settings: String { tr("Settings", "Ayarlar", "Einstellungen", "Paramètres", "Ajustes", "設定", "设置") }
    static var quit: String { tr("Quit", "Çıkış", "Beenden", "Quitter", "Salir", "終了", "退出") }
    static var about: String { tr("About DodoNest", "DodoNest Hakkında", "Über DodoNest", "À propos de DodoNest", "Acerca de DodoNest", "DodoNestについて", "关于DodoNest") }

    // MARK: - Navigation
    static var layout: String { tr("Layout", "Düzen", "Layout", "Disposition", "Diseño", "レイアウト", "布局") }
    static var appearance: String { tr("Appearance", "Görünüm", "Erscheinungsbild", "Apparence", "Apariencia", "外観", "外观") }
    static var hotkeys: String { tr("Hotkeys", "Kısayollar", "Tastenkürzel", "Raccourcis", "Atajos", "ホットキー", "快捷键") }

    // MARK: - Layout View
    static var menuBarLayout: String { tr("Menu bar layout", "Menü çubuğu düzeni", "Menüleisten-Layout", "Disposition de la barre de menus", "Diseño de la barra de menús", "メニューバーレイアウト", "菜单栏布局") }
    static var dragAndDropToRearrange: String { tr("Drag and drop to rearrange your menu bar items", "Menü çubuğu öğelerini yeniden düzenlemek için sürükle bırak", "Ziehen Sie Elemente, um Ihre Menüleiste neu anzuordnen", "Glissez-déposez pour réorganiser vos éléments", "Arrastra y suelta para reorganizar los elementos", "ドラッグ＆ドロップで並び替え", "拖放以重新排列菜单栏项目") }
    static var menuBarItems: String { tr("Menu bar items", "Menü çubuğu öğeleri", "Menüleisten-Elemente", "Éléments de la barre de menus", "Elementos de la barra de menús", "メニューバー項目", "菜单栏项目") }
    static var itemsCurrentlyInMenuBar: String { tr("Items currently in your menu bar", "Şu anda menü çubuğundaki öğeler", "Aktuelle Elemente in Ihrer Menüleiste", "Éléments actuellement dans votre barre de menus", "Elementos actualmente en tu barra de menús", "現在メニューバーにある項目", "当前在菜单栏中的项目") }
    static var searchMenuBarItems: String { tr("Search menu bar items...", "Menü çubuğu öğelerini ara...", "Menüleisten-Elemente suchen...", "Rechercher des éléments...", "Buscar elementos...", "メニューバー項目を検索...", "搜索菜单栏项目...") }
    static var noMenuBarItemsDetected: String { tr("No menu bar items detected", "Menü çubuğu öğesi algılanmadı", "Keine Menüleisten-Elemente gefunden", "Aucun élément détecté", "No se detectaron elementos", "メニューバー項目が見つかりません", "未检测到菜单栏项目") }
    static var noItemsMatchSearch: String { tr("No items match your search", "Aramanızla eşleşen öğe yok", "Keine Elemente gefunden", "Aucun élément ne correspond", "Ningún elemento coincide", "一致する項目がありません", "没有匹配的项目") }
    static var items: String { tr("items", "öğe", "Elemente", "éléments", "elementos", "項目", "项目") }
    static var system: String { tr("System", "Sistem", "System", "Système", "Sistema", "システム", "系统") }

    // MARK: - Instructions
    static var howToReorderItems: String { tr("How to reorder menu bar items", "Menü çubuğu öğelerini yeniden sıralama", "So ordnen Sie Elemente neu an", "Comment réorganiser les éléments", "Cómo reordenar los elementos", "項目の並び替え方法", "如何重新排列项目") }
    static var dragItemInstruction: String { tr("Drag an item above onto another item to swap their positions", "Konumlarını değiştirmek için bir öğeyi diğerinin üzerine sürükleyin", "Ziehen Sie ein Element auf ein anderes, um die Positionen zu tauschen", "Faites glisser un élément sur un autre pour échanger leurs positions", "Arrastra un elemento sobre otro para intercambiar posiciones", "項目を別の項目にドラッグして位置を入れ替えます", "将一个项目拖到另一个项目上以交换位置") }
    static var commandDragInstruction: String { tr("Or hold ⌘ Command and drag items directly in your actual menu bar", "Veya ⌘ Command tuşunu basılı tutarak öğeleri doğrudan menü çubuğunda sürükleyin", "Oder halten Sie ⌘ gedrückt und ziehen Sie Elemente direkt in Ihrer Menüleiste", "Ou maintenez ⌘ et faites glisser les éléments directement dans votre barre de menus", "O mantén presionado ⌘ y arrastra los elementos directamente en tu barra de menús", "または⌘を押しながらメニューバーで直接ドラッグ", "或按住⌘直接在菜单栏中拖动项目") }
    static var movingItem: String { tr("Moving", "Taşınıyor", "Verschieben", "Déplacement", "Moviendo", "移動中", "正在移动") }

    // MARK: - Appearance View
    static var customizeMenuBarLooks: String { tr("Customize how your menu bar looks", "Menü çubuğunuzun görünümünü özelleştirin", "Passen Sie das Aussehen Ihrer Menüleiste an", "Personnalisez l'apparence de votre barre de menus", "Personaliza el aspecto de tu barra de menús", "メニューバーの見た目をカスタマイズ", "自定义菜单栏的外观") }
    static var appearanceComingSoon: String { tr("Appearance options coming soon", "Görünüm seçenekleri yakında", "Erscheinungsbild-Optionen kommen bald", "Options d'apparence bientôt disponibles", "Opciones de apariencia próximamente", "外観オプションは近日公開", "外观选项即将推出") }
    static var customizationFeaturesComingSoon: String { tr("Customization features will be available in a future update.", "Özelleştirme özellikleri gelecek bir güncellemede kullanılabilir olacak.", "Anpassungsfunktionen werden in einem zukünftigen Update verfügbar sein.", "Les fonctionnalités de personnalisation seront disponibles dans une future mise à jour.", "Las funciones de personalización estarán disponibles en una actualización futura.", "カスタマイズ機能は将来のアップデートで利用可能になります。", "自定义功能将在未来的更新中提供。") }
    static var adjustSpacing: String { tr("Adjust spacing between menu bar items", "Menü çubuğu öğeleri arasındaki boşluğu ayarla", "Abstand zwischen Elementen anpassen", "Ajuster l'espacement entre les éléments", "Ajustar el espaciado entre elementos", "項目間の間隔を調整", "调整项目之间的间距") }
    static var notchAwareLayout: String { tr("Notch-aware layout for MacBook Pro/Air", "MacBook Pro/Air için çentik uyumlu düzen", "Notch-kompatibles Layout für MacBook Pro/Air", "Disposition adaptée à l'encoche pour MacBook Pro/Air", "Diseño compatible con notch para MacBook Pro/Air", "MacBook Pro/Air向けノッチ対応レイアウト", "适配MacBook Pro/Air刘海屏的布局") }
    static var tintColorsAndThemes: String { tr("Tint colors and themes", "Renk tonları ve temalar", "Farbtöne und Themen", "Couleurs et thèmes", "Colores y temas", "カラーとテーマ", "色调和主题") }
    static var shadowsAndEffects: String { tr("Shadows and visual effects", "Gölgeler ve görsel efektler", "Schatten und visuelle Effekte", "Ombres et effets visuels", "Sombras y efectos visuales", "シャドウと視覚効果", "阴影和视觉效果") }

    // MARK: - Hotkeys View
    static var keyboardShortcuts: String { tr("Keyboard shortcuts", "Klavye kısayolları", "Tastaturkürzel", "Raccourcis clavier", "Atajos de teclado", "キーボードショートカット", "键盘快捷键") }
    static var configureGlobalHotkeys: String { tr("Configure global hotkeys for quick actions", "Hızlı eylemler için genel kısayolları yapılandırın", "Globale Tastenkürzel für schnelle Aktionen konfigurieren", "Configurez des raccourcis globaux pour des actions rapides", "Configura atajos globales para acciones rápidas", "クイックアクション用のグローバルホットキーを設定", "配置全局快捷键以执行快速操作") }
    static var hotkeysComingSoon: String { tr("Hotkeys coming soon", "Kısayollar yakında", "Tastenkürzel kommen bald", "Raccourcis bientôt disponibles", "Atajos próximamente", "ホットキーは近日公開", "快捷键即将推出") }
    static var hotkeysFeaturesComingSoon: String { tr("Global keyboard shortcuts will be available in a future update.", "Genel klavye kısayolları gelecek bir güncellemede kullanılabilir olacak.", "Globale Tastaturkürzel werden in einem zukünftigen Update verfügbar sein.", "Les raccourcis clavier globaux seront disponibles dans une future mise à jour.", "Los atajos de teclado globales estarán disponibles en una actualización futura.", "グローバルキーボードショートカットは将来のアップデートで利用可能になります。", "全局键盘快捷键将在未来的更新中提供。") }
    static var toggleHiddenItems: String { tr("Toggle hidden items", "Gizli öğeleri göster/gizle", "Ausgeblendete Elemente umschalten", "Basculer les éléments masqués", "Alternar elementos ocultos", "非表示項目の切り替え", "切换隐藏项目") }
    static var toggleDodoNestBar: String { tr("Toggle DodoNest bar", "DodoNest çubuğunu göster/gizle", "DodoNest-Leiste umschalten", "Basculer la barre DodoNest", "Alternar barra DodoNest", "DodoNestバーの切り替え", "切换DodoNest栏") }

    // MARK: - Settings View
    static var generalSettings: String { tr("General settings", "Genel ayarlar", "Allgemeine Einstellungen", "Paramètres généraux", "Ajustes generales", "一般設定", "常规设置") }
    static var configureBasicBehavior: String { tr("Configure basic app behavior", "Temel uygulama davranışını yapılandırın", "Grundlegendes App-Verhalten konfigurieren", "Configurez le comportement de base de l'application", "Configura el comportamiento básico de la aplicación", "基本的なアプリの動作を設定", "配置基本应用行为") }
    static var configureDodoNestBehavior: String { tr("Configure DodoNest behavior", "DodoNest davranışını yapılandırın", "DodoNest-Verhalten konfigurieren", "Configurez le comportement de DodoNest", "Configura el comportamiento de DodoNest", "DodoNestの動作を設定", "配置DodoNest行为") }
    static var startup: String { tr("Startup", "Başlangıç", "Start", "Démarrage", "Inicio", "起動", "启动") }
    static var launchAtLogin: String { tr("Launch at login", "Oturum açılışında başlat", "Bei Anmeldung starten", "Lancer au démarrage", "Iniciar sesión", "ログイン時に起動", "登录时启动") }
    static var automaticallyStartWhenLogin: String { tr("Automatically start DodoNest when you log in", "Oturum açtığınızda DodoNest'i otomatik olarak başlat", "DodoNest automatisch starten, wenn Sie sich anmelden", "Démarrer automatiquement DodoNest à la connexion", "Iniciar DodoNest automáticamente al iniciar sesión", "ログイン時にDodoNestを自動的に起動", "登录时自动启动DodoNest") }
    static var showMenuBarIcon: String { tr("Show DodoNest icon in menu bar", "Menü çubuğunda DodoNest simgesini göster", "DodoNest-Symbol in Menüleiste anzeigen", "Afficher l'icône DodoNest dans la barre", "Mostrar icono de DodoNest en la barra", "メニューバーにDodoNestアイコンを表示", "在菜单栏中显示DodoNest图标") }
    static var displayIconInMenuBar: String { tr("Display the DodoNest icon for quick access", "Hızlı erişim için DodoNest simgesini görüntüle", "DodoNest-Symbol für schnellen Zugriff anzeigen", "Afficher l'icône pour un accès rapide", "Mostrar el icono para acceso rápido", "クイックアクセス用にアイコンを表示", "显示图标以便快速访问") }
    static var moreSettingsComingSoon: String { tr("More settings coming soon", "Daha fazla ayar yakında", "Weitere Einstellungen kommen bald", "Plus de paramètres bientôt", "Más ajustes próximamente", "その他の設定は近日公開", "更多设置即将推出") }
    static var moreSettingsDescription: String { tr("Click-to-reveal, hover-to-reveal, auto-rehide, and DodoNest bar options are planned for a future update.", "Tıkla-göster, üzerine gel-göster, otomatik gizleme ve DodoNest çubuğu seçenekleri gelecek bir güncellemede planlanıyor.", "Klick-zum-Anzeigen, Hover-zum-Anzeigen, Auto-Verstecken und DodoNest-Leisten-Optionen sind für ein zukünftiges Update geplant.", "Les options clic-pour-révéler, survol-pour-révéler, auto-masquage et barre DodoNest sont prévues pour une future mise à jour.", "Las opciones de clic-para-revelar, pasar-para-revelar, auto-ocultar y barra DodoNest están planificadas para una actualización futura.", "クリックで表示、ホバーで表示、自動非表示、DodoNestバーオプションは将来のアップデートで予定されています。", "点击显示、悬停显示、自动隐藏和DodoNest栏选项计划在未来更新中提供。") }
    static var resetAllSettings: String { tr("Reset all settings", "Tüm ayarları sıfırla", "Alle Einstellungen zurücksetzen", "Réinitialiser tous les paramètres", "Restablecer todos los ajustes", "すべての設定をリセット", "重置所有设置") }
    static var customizableKeyCombinations: String { tr("Customizable key combinations", "Özelleştirilebilir tuş kombinasyonları", "Anpassbare Tastenkombinationen", "Combinaisons de touches personnalisables", "Combinaciones de teclas personalizables", "カスタマイズ可能なキーの組み合わせ", "可自定义的组合键") }
    static var keyboardShortcutsDescription: String { tr("Keyboard shortcuts for quick access", "Hızlı erişim için klavye kısayolları", "Tastaturkürzel für schnellen Zugriff", "Raccourcis clavier pour un accès rapide", "Atajos de teclado para acceso rápido", "クイックアクセス用キーボードショートカット", "快捷键以便快速访问") }
    static var hotkeysWhenHidingFeatures: String { tr("Global keyboard shortcuts will be available in a future update when hiding features are implemented.", "Gizleme özellikleri uygulandığında genel klavye kısayolları gelecek bir güncellemede kullanılabilir olacak.", "Globale Tastaturkürzel werden verfügbar sein, wenn Versteck-Funktionen implementiert sind.", "Les raccourcis clavier globaux seront disponibles lorsque les fonctionnalités de masquage seront implémentées.", "Los atajos globales estarán disponibles cuando se implementen las funciones de ocultar.", "非表示機能が実装されたときにグローバルショートカットが利用可能になります。", "当隐藏功能实现后，全局快捷键将可用。") }
    static var showHideDodoNestBar: String { tr("Show/hide the DodoNest bar", "DodoNest çubuğunu göster/gizle", "DodoNest-Leiste ein-/ausblenden", "Afficher/masquer la barre DodoNest", "Mostrar/ocultar la barra DodoNest", "DodoNestバーの表示/非表示", "显示/隐藏DodoNest栏") }
    static var toggleHiddenItemsVisibility: String { tr("Toggle hidden items visibility", "Gizli öğelerin görünürlüğünü değiştir", "Sichtbarkeit versteckter Elemente umschalten", "Basculer la visibilité des éléments masqués", "Alternar visibilidad de elementos ocultos", "非表示項目の表示を切り替え", "切换隐藏项目的可见性") }

    // MARK: - Accessibility
    static var accessibilityPermissionRequired: String { tr("Accessibility permission required", "Erişilebilirlik izni gerekli", "Bedienungshilfen-Berechtigung erforderlich", "Autorisation d'accessibilité requise", "Se requiere permiso de accesibilidad", "アクセシビリティ権限が必要です", "需要辅助功能权限") }
    static var accessibilityDescription: String { tr("DodoNest needs Accessibility access to move and arrange your menu bar items.", "DodoNest, menü çubuğu öğelerinizi taşımak ve düzenlemek için Erişilebilirlik erişimine ihtiyaç duyar.", "DodoNest benötigt Bedienungshilfen-Zugriff, um Ihre Menüleisten-Elemente zu verschieben.", "DodoNest a besoin de l'accès d'accessibilité pour déplacer vos éléments de barre de menus.", "DodoNest necesita acceso de accesibilidad para mover los elementos de la barra de menús.", "DodoNestはメニューバー項目を移動するためにアクセシビリティアクセスが必要です。", "DodoNest需要辅助功能权限来移动和排列菜单栏项目。") }
    static var openSystemSettings: String { tr("Open System Settings", "Sistem Ayarlarını Aç", "Systemeinstellungen öffnen", "Ouvrir les Préférences Système", "Abrir Ajustes del Sistema", "システム設定を開く", "打开系统设置") }
    static var showInFinder: String { tr("Show in Finder", "Finder'da Göster", "Im Finder anzeigen", "Afficher dans le Finder", "Mostrar en Finder", "Finderで表示", "在访达中显示") }
    static var restartApp: String { tr("Restart DodoNest", "DodoNest'i Yeniden Başlat", "DodoNest neu starten", "Redémarrer DodoNest", "Reiniciar DodoNest", "DodoNestを再起動", "重新启动DodoNest") }
    static var illDoThisLater: String { tr("I'll do this later", "Bunu daha sonra yapacağım", "Ich mache das später", "Je ferai ça plus tard", "Lo haré más tarde", "後でやります", "稍后再说") }
    static var permissionGranted: String { tr("Permission granted!", "İzin verildi!", "Berechtigung erteilt!", "Autorisation accordée!", "¡Permiso concedido!", "権限が付与されました！", "权限已授予！") }
    static var continueButton: String { tr("Continue", "Devam", "Weiter", "Continuer", "Continuar", "続ける", "继续") }
    static var grantAccess: String { tr("Grant access", "Erişim izni ver", "Zugriff gewähren", "Accorder l'accès", "Conceder acceso", "アクセスを許可", "授予访问权限") }
    static var enableThenRestart: String { tr("Enable in System Settings, then restart app", "Sistem Ayarlarında etkinleştirin, ardından uygulamayı yeniden başlatın", "In Systemeinstellungen aktivieren, dann App neu starten", "Activer dans les Préférences Système, puis redémarrer", "Habilitar en Ajustes del Sistema, luego reiniciar", "システム設定で有効にしてアプリを再起動", "在系统设置中启用，然后重启应用") }
    static var ifAlreadyEnabledNotWorking: String { tr("If already enabled but not working:", "Zaten etkinleştirildi ancak çalışmıyorsa:", "Falls bereits aktiviert, aber nicht funktioniert:", "Si déjà activé mais ne fonctionne pas:", "Si ya está habilitado pero no funciona:", "既に有効になっているが動作しない場合：", "如果已启用但不工作：") }
    static var accessibilitySteps: String { tr("1. Remove DodoNest from Accessibility list\n2. Click \"Show in Finder\" below, then drag the app to Accessibility\n3. Restart the app", "1. DodoNest'i Erişilebilirlik listesinden kaldırın\n2. Aşağıdaki \"Finder'da Göster\"e tıklayın, ardından uygulamayı Erişilebilirlik'e sürükleyin\n3. Uygulamayı yeniden başlatın", "1. DodoNest aus der Bedienungshilfen-Liste entfernen\n2. Unten auf \"Im Finder anzeigen\" klicken, dann die App zu Bedienungshilfen ziehen\n3. App neu starten", "1. Retirer DodoNest de la liste d'accessibilité\n2. Cliquer sur \"Afficher dans le Finder\" ci-dessous, puis glisser l'app vers Accessibilité\n3. Redémarrer l'app", "1. Eliminar DodoNest de la lista de Accesibilidad\n2. Hacer clic en \"Mostrar en Finder\" abajo, luego arrastrar la app a Accesibilidad\n3. Reiniciar la app", "1. アクセシビリティリストからDodoNestを削除\n2. 下の「Finderで表示」をクリックし、アプリをアクセシビリティにドラッグ\n3. アプリを再起動", "1. 从辅助功能列表中移除DodoNest\n2. 点击下方\"在访达中显示\"，然后将应用拖到辅助功能\n3. 重新启动应用") }

    // MARK: - Menu Bar Popover
    static var openSettings: String { tr("Open Settings", "Ayarları Aç", "Einstellungen öffnen", "Ouvrir les paramètres", "Abrir Ajustes", "設定を開く", "打开设置") }
    static var refreshItems: String { tr("Refresh Items", "Öğeleri Yenile", "Elemente aktualisieren", "Actualiser les éléments", "Actualizar elementos", "項目を更新", "刷新项目") }
    static var view: String { tr("View", "Görünüm", "Ansicht", "Affichage", "Vista", "表示", "视图") }
    static var actions: String { tr("Actions", "Eylemler", "Aktionen", "Actions", "Acciones", "アクション", "操作") }
    static var refreshMenuBarItems: String { tr("Refresh menu bar items", "Menü çubuğu öğelerini yenile", "Menüleisten-Elemente aktualisieren", "Actualiser les éléments de la barre de menus", "Actualizar elementos de la barra de menús", "メニューバー項目を更新", "刷新菜单栏项目") }

    // MARK: - Helper

    private static func tr(_ en: String, _ tr: String, _ de: String, _ fr: String, _ es: String, _ ja: String, _ zh: String) -> String {
        switch current {
        case .english: return en
        case .turkish: return tr
        case .german: return de
        case .french: return fr
        case .spanish: return es
        case .japanese: return ja
        case .chinese: return zh
        }
    }
}

// MARK: - Notification

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
