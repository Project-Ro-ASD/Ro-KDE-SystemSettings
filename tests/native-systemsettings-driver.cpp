// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-only
// TEST ONLY: linked into the original upstream systemsettings target in a
// disposable build. Never added to the prototype RPM or production patch.
#include "SidebarMode.h"
#include "ModuleView.h"
#include <KCModule>
#include <KConfigGroup>
#include <KSharedConfig>
#include <KPluginMetaData>
#include <KLocalizedString>
#include <QAbstractButton>
#include <QApplication>
#include <QAbstractItemModel>
#include <QDialogButtonBox>
#include <QFile>
#include <QFont>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMenu>
#include <QPushButton>
#include <QQuickItem>
#include <QQuickWidget>
#include <QQmlContext>
#include <QTest>
#include <QTimer>

static QJsonArray checks;
static QJsonArray limitations;
#define CHECK_NATIVE(condition, label) \
    do { \
        checks.append(QJsonObject{{QStringLiteral("check"), QStringLiteral(label)}, {QStringLiteral("passed"), bool(condition)}}); \
        if (!(condition)) { finish(1); return; } \
    } while (false)

static void finish(int code)
{
    for (auto *window : QApplication::topLevelWidgets()) {
        if (window->isVisible() && !qEnvironmentVariableIsEmpty("RO_NATIVE_TEST_SCREENSHOT")) {
            window->grab().save(qEnvironmentVariable("RO_NATIVE_TEST_SCREENSHOT"));
            break;
        }
    }
    QFile result(qEnvironmentVariable("RO_NATIVE_TEST_RESULT"));
    if (!result.open(QIODevice::WriteOnly)) {
        qCritical() << "Cannot write native test results";
        qApp->exit(2);
        return;
    }
    result.write(QJsonDocument(QJsonObject{{QStringLiteral("checks"), checks},
        {QStringLiteral("limitations"), limitations},
        {QStringLiteral("platform"), QGuiApplication::platformName()},
        {QStringLiteral("test_driver"), true},
        {QStringLiteral("production_binary"), false}}).toJson());
    qApp->exit(code);
}

static QQuickItem *itemNamed(QQuickItem *root, const QString &name)
{
    if (!root) return nullptr;
    if (root->objectName() == name) return root;
    for (auto *child : root->childItems()) {
        if (auto *match = itemNamed(child, name)) return match;
    }
    return nullptr;
}

static void clickQuick(QQuickWidget *widget, QQuickItem *item)
{
    const QPointF center = item->mapToScene(QPointF(item->width() / 2, item->height() / 2));
    QTest::mouseClick(widget, Qt::LeftButton, Qt::NoModifier, center.toPoint());
    QTest::qWait(250);
}

static QPushButton *nativeButton(ModuleView *view, QDialogButtonBox::StandardButton which)
{
    for (auto *box : view->findChildren<QDialogButtonBox *>()) {
        if (auto *button = box->button(which)) return button;
    }
    return nullptr;
}

static void runNativeTest()
{
    SidebarMode *sidebar = nullptr;
    QWidget *window = nullptr;
    for (auto *widget : QApplication::topLevelWidgets()) {
        if (auto *candidate = widget->findChild<SidebarMode *>()) {
            sidebar = candidate;
            window = widget;
            break;
        }
    }
    CHECK_NATIVE(sidebar && window, "original KDE window and SidebarMode exist");
    KLocalizedString::setLanguages({qEnvironmentVariable("RO_NATIVE_TEST_LANGUAGE")});
    sidebar->retranslateQml();
    QTest::qWait(150);
    window->resize(1200, 850);
    QTest::qWait(300);
    QQuickWidget *quick = nullptr;
    for (auto *widget : window->findChildren<QQuickWidget *>()) {
        if (widget->rootContext()->contextProperty(QStringLiteral("systemsettings")).value<QObject *>() == sidebar
            && widget->rootObject() && widget->rootObject()->property("headerHeight").isValid()) {
            quick = widget;
            break;
        }
    }
    CHECK_NATIVE(quick, "native QQuickWidget uses the original KDE context");
    const bool isRo = quick->rootObject()->objectName() == QStringLiteral("roNativeSidebar");
    const bool expectRo = qEnvironmentVariable("RO_NATIVE_TEST_EXPECT") == QStringLiteral("ro");
    CHECK_NATIVE(isRo == expectRo, "expected Ro or stock root selected");
    CHECK_NATIVE(sidebar->categoryModel()->rowCount() > 0, "native category model is populated");
    if (isRo) {
        auto *field = itemNamed(quick->rootObject(), QStringLiteral("roSearchField"));
        const QString expected = qEnvironmentVariable("RO_NATIVE_TEST_LANGUAGE") == QStringLiteral("tr")
            ? QStringLiteral("Ayarlarda ara") : QStringLiteral("Search settings");
        if (field && field->property("placeholderText").toString() != expected) {
            limitations.append(QStringLiteral("Translation diagnostic: languages=%1; catalog=%2; QML=%3")
                .arg(KLocalizedString::languages().join(QStringLiteral(",")),
                     i18nd("ro-systemsettings-native-skin", "Search settings"),
                     field->property("placeholderText").toString()));
        }
        CHECK_NATIVE(field && field->property("placeholderText").toString() == expected,
                     "Ro strings use the existing KDE localization context");
    }
    if (qEnvironmentVariable("RO_NATIVE_TEST_CASE") != QStringLiteral("ui")) {
        finish(0);
        return;
    }
    CHECK_NATIVE(isRo, "UI interaction test runs inside Ro visual root");
    auto *root = quick->rootObject();
    auto *menu = itemNamed(root, QStringLiteral("roActionMenu"));
    CHECK_NATIVE(menu, "Ro menu control exists");
    clickQuick(quick, menu);
    auto *popup = QApplication::activePopupWidget();
    QMenu *nativeMenu = qobject_cast<QMenu *>(popup);
    if (!nativeMenu) {
        for (auto *widget : QApplication::topLevelWidgets()) {
            if (auto *candidate = qobject_cast<QMenu *>(widget)) { nativeMenu = candidate; break; }
        }
    }
    CHECK_NATIVE(nativeMenu && nativeMenu->actions().contains(sidebar->action(QStringLiteral("help_about_app"))),
                 "Ro menu delegates to the original KDE menu and QAction objects");
    if (popup) QTest::keyClick(popup, Qt::Key_Escape);
    else {
        limitations.append(QStringLiteral("Wayland popup grab NOT VERIFIED: synthetic QtTest input carries no compositor input serial"));
        nativeMenu->hide();
    }
    int categoryRow = -1;
    for (int row = 0; row < sidebar->categoryModel()->rowCount(); ++row) {
        if (sidebar->categoryModel()->rowCount(sidebar->categoryModel()->index(row, 0)) > 0) {
            categoryRow = row;
            break;
        }
    }
    CHECK_NATIVE(categoryRow >= 0, "native model contains an expandable category");
    auto *card = itemNamed(root, QStringLiteral("roCategory_%1").arg(categoryRow));
    CHECK_NATIVE(card, "Ro category card instantiated");
    if (root->property("expandedRow").toInt() == categoryRow) clickQuick(quick, card);
    clickQuick(quick, card);
    CHECK_NATIVE(sidebar->activeCategoryRow() == categoryRow, "category card activates native navigation");
    CHECK_NATIVE(root->property("expandedRow").toInt() == categoryRow, "native category expands accordion");
    if (sidebar->subCategoryModel()->rowCount() > 0) {
        auto *sub = itemNamed(root, QStringLiteral("roSubcategory_0"));
        CHECK_NATIVE(sub, "accordion exposes native subcategory delegate");
        clickQuick(quick, sub);
        CHECK_NATIVE(sidebar->activeSubCategoryRow() == 0, "subcategory activates native navigation");
    }
    clickQuick(quick, card);
    CHECK_NATIVE(root->property("expandedRow").toInt() == -1, "accordion can collapse");
    auto *search = itemNamed(root, QStringLiteral("roSearchField"));
    CHECK_NATIVE(search, "Ro search field exists");
    search->forceActiveFocus();
    QTest::keyClicks(quick, QStringLiteral("Fonts"));
    QTest::qWait(500);
    CHECK_NATIVE(root->property("searching").toBool(), "typing enters search mode");
    CHECK_NATIVE(sidebar->searchModel()->rowCount() > 0, "original KDE search returns real modules");
    QQuickItem *result = nullptr;
    for (int row = 0; row < sidebar->searchModel()->rowCount(); ++row) {
        auto *candidate = itemNamed(root, QStringLiteral("roCategory_%1").arg(row));
        if (candidate && candidate->isEnabled()) { result = candidate; break; }
    }
    CHECK_NATIVE(result, "native search result has a Ro delegate");
    clickQuick(quick, result);
    CHECK_NATIVE(sidebar->moduleView()->activeModuleMetadata().pluginId() == QStringLiteral("kcm_fonts"),
                 "search result activates the real Fonts module in native ModuleView");
    CHECK_NATIVE(!sidebar->moduleView()->findChildren<KCModule *>().isEmpty(), "real KDE KCM instantiated by ModuleView");
    search->setProperty("text", QString());
    QTest::qWait(200);

    // Exercise the REAL Fonts KCM backend already loaded by the UI search.
    // Plasma Renderer has no System Settings parent-category metadata and must
    // not be added to the native model just to make a test pass.
    auto *view = sidebar->moduleView();
    QObject *setting = nullptr;
    for (auto *object : view->findChildren<QObject *>()) {
        const QVariant candidate = object->property("fontsSettings");
        if (candidate.isValid()) { setting = candidate.value<QObject *>(); break; }
    }
    CHECK_NATIVE(setting && setting->property("font").canConvert<QFont>(), "real Fonts KCM exposes its native font setting");
    auto *apply = nativeButton(view, QDialogButtonBox::Apply);
    auto *reset = nativeButton(view, QDialogButtonBox::Reset);
    auto *defaults = nativeButton(view, QDialogButtonBox::RestoreDefaults);
    CHECK_NATIVE(apply && reset && defaults, "original KDE Apply Reset Defaults buttons present");
    const QFont original = setting->property("font").value<QFont>();
    QFont changed = original;
    changed.setPointSizeF(original.pointSizeF() + 1);
    CHECK_NATIVE(setting->setProperty("font", changed), "real KCM setting accepts a temporary font change");
    QTest::qWait(100);
    CHECK_NATIVE(apply->isEnabled(), "real KCM change enables original Apply");
    QTest::mouseClick(reset, Qt::LeftButton);
    CHECK_NATIVE(setting->property("font").value<QFont>() == original, "original Reset reloads real setting");
    setting->setProperty("font", changed);
    QTest::qWait(150);
    CHECK_NATIVE(apply->isEnabled(), "original Apply is enabled after Reset and second change");
    QTest::mouseClick(apply, Qt::LeftButton);
    QTest::qWait(500);
    auto config = KSharedConfig::openConfig(QStringLiteral("kdeglobals"));
    config->reparseConfiguration();
    const QFont persisted = KConfigGroup(config, QStringLiteral("General")).readEntry("font", original);
    CHECK_NATIVE(persisted.family() == changed.family() && qFuzzyCompare(persisted.pointSizeF(), changed.pointSizeF()),
                 "original Apply writes the real Fonts configuration");
    QTest::mouseClick(defaults, Qt::LeftButton);
    QTest::qWait(100);
    CHECK_NATIVE(setting->property("font").value<QFont>() == original,
                 "original Defaults restores the clean-HOME font default");
    if (apply->isEnabled()) QTest::mouseClick(apply, Qt::LeftButton);
    config->reparseConfiguration();
    // KConfig may remove an entry when its native default is restored.
    const QFont restored = KConfigGroup(config, QStringLiteral("General")).readEntry("font", original);
    CHECK_NATIVE(restored.family() == original.family() && qFuzzyCompare(restored.pointSizeF(), original.pointSizeF()),
                 "restored default is persisted through original Apply");
    view->moduleLoad();
    CHECK_NATIVE(setting->property("font").value<QFont>() == original,
                 "original KCM reload reads the restored configuration");
    window->grab().save(qEnvironmentVariable("RO_NATIVE_TEST_SCREENSHOT"));
    finish(0);
}

static void startNativeTest()
{
    if (!qEnvironmentVariableIsEmpty("RO_NATIVE_TEST_CASE")) {
        KLocalizedString::setLanguages({qEnvironmentVariable("RO_NATIVE_TEST_LANGUAGE")});
        QTimer::singleShot(1000, qApp, runNativeTest);
    }
}
Q_COREAPP_STARTUP_FUNCTION(startNativeTest)
