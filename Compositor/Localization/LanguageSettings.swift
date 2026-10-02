import SwiftUI

func localizedKey(_ key: String) -> LocalizedStringKey {
    LocalizedStringKey(key)
}

/// Resolves strings for AppKit views, which do not inherit SwiftUI's locale environment.
func localizedAppString(_ key: String) -> String {
    let language = UserDefaults.standard.string(forKey: "compositor.language") ?? AppLanguage.chinese.rawValue
    if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
       let bundle = Bundle(path: path) {
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    return Bundle.main.localizedString(forKey: key, value: key, table: nil)
}

func localizedAppFormat(_ key: String, _ arguments: CVarArg...) -> String {
    let language = UserDefaults.standard.string(forKey: "compositor.language") ?? AppLanguage.chinese.rawValue
    return String(format: localizedAppString(key), locale: Locale(identifier: language), arguments: arguments)
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case chinese = "zh-Hans"
    case english = "en"
    case spanish = "es"
    case hindi = "hi"
    case french = "fr"
    case arabic = "ar"
    case portuguese = "pt-BR"
    case russian = "ru"
    case italian = "it"
    case japanese = "ja"

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .chinese: "简体中文"
        case .english: "English"
        case .spanish: "Español"
        case .hindi: "हिन्दी"
        case .french: "Français"
        case .arabic: "العربية"
        case .portuguese: "Português (Brasil)"
        case .russian: "Русский"
        case .italian: "Italiano"
        case .japanese: "日本語"
        }
    }

    var menuTitle: String {
        switch self {
        case .chinese: "语言"
        case .english: "Language"
        case .spanish: "Idioma"
        case .hindi: "भाषा"
        case .french: "Langue"
        case .arabic: "اللغة"
        case .portuguese: "Idioma"
        case .russian: "Язык"
        case .italian: "Lingua"
        case .japanese: "言語"
        }
    }
}

/// The copy on the language chooser is kept here so first launch remains understandable before
/// the rest of the app has a translated string catalog.
struct LanguagePickerView: View {
    @Binding var selection: String
    let onContinue: () -> Void

    private var language: AppLanguage {
        AppLanguage(rawValue: selection) ?? .chinese
    }

    var body: some View {
        VStack(spacing: 18) {
            Text(copy.title).font(.title2.weight(.semibold))
            Text(copy.message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Picker(copy.language, selection: $selection) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.nativeName).tag(language.rawValue)
                }
            }
            .labelsHidden()
            .frame(width: 250)
            Button(copy.continueLabel, action: onContinue)
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(30)
        .frame(width: 390)
        .environment(\.layoutDirection, language == .arabic ? .rightToLeft : .leftToRight)
    }

    private var copy: (title: String, message: String, language: String, continueLabel: String) {
        switch language {
        case .chinese: ("选择语言", "选择 Compositor 的显示语言。之后可以随时在应用菜单中更改。", "语言", "继续")
        case .english: ("Choose a language", "Choose the display language for Compositor. You can change it later from the app menu.", "Language", "Continue")
        case .spanish: ("Elige un idioma", "Elige el idioma de Compositor. Puedes cambiarlo más tarde desde el menú de la app.", "Idioma", "Continuar")
        case .hindi: ("भाषा चुनें", "Compositor की भाषा चुनें। आप इसे बाद में ऐप मेनू से बदल सकते हैं।", "भाषा", "जारी रखें")
        case .french: ("Choisir une langue", "Choisissez la langue de Compositor. Vous pourrez la modifier plus tard dans le menu de l’app.", "Langue", "Continuer")
        case .arabic: ("اختر اللغة", "اختر لغة Compositor. يمكنك تغييرها لاحقًا من قائمة التطبيق.", "اللغة", "متابعة")
        case .portuguese: ("Escolha um idioma", "Escolha o idioma do Compositor. Você pode alterá-lo depois no menu do app.", "Idioma", "Continuar")
        case .russian: ("Выберите язык", "Выберите язык Compositor. Его можно изменить позже в меню приложения.", "Язык", "Продолжить")
        case .italian: ("Scegli una lingua", "Scegli la lingua di Compositor. Potrai cambiarla in seguito dal menu dell’app.", "Lingua", "Continua")
        case .japanese: ("言語を選択", "Compositor の表示言語を選んでください。言語は後からアプリメニューで変更できます。", "言語", "続ける")
        }
    }
}
