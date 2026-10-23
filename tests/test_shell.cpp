// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-or-later
// Isolated test KCM is never installed in the product. Real KCM smoke is separate.
#include "shell.h"
#include <KCModule>
#include <QQuickWidget>
#include <QQuickItem>
#include <QSignalSpy>
#include <QTest>
#include <QTimer>
#include <QDir>
#include <algorithm>
#include <QMessageBox>
#include <QPushButton>
#include <QCheckBox>
#include <QFileInfo>
#include <QStandardPaths>
#include <KConfig>
#include <KConfigGroup>

class ShellTest : public QObject {
    Q_OBJECT
    static QQuickItem *findItem(QQuickItem *parent, const QString &name) {
        if (parent->objectName() == name) return parent;
        for (auto child : parent->childItems()) if (auto found = findItem(child, name)) return found;
        return nullptr;
    }
    static void capture(Shell &shell, const QString &name) {
        if (!qEnvironmentVariable("RO_SCREENSHOT_DIR").isEmpty()) {
            QTest::qWait(100);
            QVERIFY(shell.grab().save(qEnvironmentVariable("RO_SCREENSHOT_DIR") + "/" + name + ".png"));
        }
    }
    static void click(QQuickWidget *view, QQuickItem *item) {
        QVERIFY(item);
        QVERIFY(item->isVisible());
        const QPoint point = item->mapToScene(QPointF(item->width()/2, item->height()/2)).toPoint();
        QTest::mouseClick(view, Qt::LeftButton, Qt::NoModifier, point);
        QTest::qWait(100);
    }
private Q_SLOTS:
    void activeRoControls() {
        Shell shell;
        shell.show();
        QVERIFY(shell.qmlReady());
        auto navigation = shell.findChildren<QQuickWidget *>().first();
        QCOMPARE(navigation->source().toString(), QStringLiteral("qrc:/ro/org/ro/systemsettings/Main.qml"));
        auto root = navigation->rootObject();
        QVERIFY(root);
        QCOMPARE(root->objectName(), QStringLiteral("roCatalog"));
        auto sidebar = root->findChild<QQuickItem *>(QStringLiteral("roSidebar"));
        QVERIFY(sidebar);
        QVERIFY(sidebar->isVisible());
        auto search = root->findChild<QObject *>(QStringLiteral("settingsSearch"));
        QVERIFY(search);
        // Narrow to a visible card so the test sends real mouse input, independent of scroll position.
        search->setProperty("text", QStringLiteral("ro_test_kcm"));
        QTest::qWait(100);
        auto card = findItem(root, QStringLiteral("moduleCard_ro_test_kcm"));
        QVERIFY(card);
        capture(shell, QStringLiteral("ro-card"));
        click(navigation, card);
        QTRY_COMPARE(shell.currentId(), QStringLiteral("ro_test_kcm"));
        QVERIFY2(shell.error().isEmpty(), qPrintable(shell.error()));
        QVERIFY(shell.findChild<QPushButton *>(QStringLiteral("editTestValue")));
        shell.home();
        // A private three-level metadata fixture exercises the actual category reader/filter.
        auto category = findItem(root, QStringLiteral("categoryToggle_ro-test-top"));
        QVERIFY(category);
        click(navigation, category);
        QCOMPARE(root->property("expandedCategory").toString(), QStringLiteral("ro-test-top"));
        auto subcategory = findItem(root, QStringLiteral("subcategory_ro-test-middle"));
        QVERIFY(subcategory);
        click(navigation, subcategory);
        QCOMPARE(root->property("selectedCategory").toString(), QStringLiteral("ro-test-middle"));
        QCOMPARE(root->property("filteredCount").toInt(), 1);
        capture(shell, QStringLiteral("ro-accordion"));
        auto entry = findItem(root, QStringLiteral("categoryModule_ro_test_kcm"));
        QVERIFY(entry);
        click(navigation, entry);
        QTRY_COMPARE(shell.currentId(), QStringLiteral("ro_test_kcm"));
        QVERIFY2(shell.error().isEmpty(), qPrintable(shell.error()));
        QVERIFY(shell.findChild<QPushButton *>(QStringLiteral("editTestValue")));
        shell.home();
        click(navigation, category);
        QCOMPARE(root->property("expandedCategory").toString(), QString());
        // History tabs use the same real navigation path and keep only one KCM instantiated.
        shell.open(QStringLiteral("ro_test_kcm"));
        QQuickWidget *headerView = nullptr;
        for (auto view : shell.findChildren<QQuickWidget *>())
            if (view->source().path().endsWith(QStringLiteral("ModuleHeader.qml"))) headerView = view;
        QVERIFY(headerView);
        auto header = headerView->rootObject();
        QVERIFY(header);
        QString second;
        for (const auto &module : Shell::discover()) {
            if (QStringList{"kcm_qtquicksettings", "kcm_fonts", "kcm_colors"}.contains(module.pluginId())) { second = module.pluginId(); break; }
        }
        QVERIFY(!second.isEmpty());
        shell.home();
        search->setProperty("text", second);
        QTest::qWait(100);
        auto realCard = findItem(root, QStringLiteral("moduleCard_") + second);
        QVERIFY(realCard);
        capture(shell, QStringLiteral("real-ro-card"));
        click(navigation, realCard);
        QTRY_COMPARE(shell.currentId(), second);
        QVERIFY2(shell.error().isEmpty(), qPrintable(shell.error()));
        capture(shell, QStringLiteral("real-ro-kcm"));
        QTRY_VERIFY(findItem(header, QStringLiteral("historyTab_ro_test_kcm")));
        click(headerView, findItem(header, QStringLiteral("historyTab_ro_test_kcm")));
        QTRY_COMPARE(shell.currentId(), QStringLiteral("ro_test_kcm"));
        QVERIFY2(shell.error().isEmpty(), qPrintable(shell.error()));
        QCOMPARE(shell.findChildren<KCModule *>().size(), 1);
        capture(shell, QStringLiteral("ro-tabs"));
        shell.home();
        capture(shell, QStringLiteral("ro-sidebar"));
    }
    void realKcmPersistence() {
        const auto installed = Shell::discover();
        const bool available = std::any_of(installed.cbegin(), installed.cend(), [](const auto &m) { return m.pluginId() == "kcm_qtquicksettings"; });
        if (!available) {
            QVERIFY2(!qEnvironmentVariableIsSet("RO_REQUIRE_REAL_QTW_SAVE"), "Required real QtWidgets KCM is absent");
            QSKIP("kcm_qtquicksettings unavailable in this module set; extended CI requires it");
        }
        // Never write a live profile: only disposable run-shell-unit.sh environments qualify.
        QVERIFY(QFileInfo::exists(QStringLiteral("/run/.containerenv")) || QFileInfo::exists(QStringLiteral("/.dockerenv")));
        const QString directory = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
        QVERIFY(directory.startsWith(QDir::tempPath() + QLatin1Char('/')));
        Shell shell;
        shell.show();
        shell.open(QStringLiteral("kcm_qtquicksettings"));
        QVERIFY2(shell.error().isEmpty(), qPrintable(shell.error()));
        auto control = shell.findChild<QCheckBox *>(QStringLiteral("kcfg_ForceGlCoreProfile"));
        QVERIFY(control);
        const bool original = control->isChecked();
        control->setChecked(!original);
        QTRY_VERIFY(shell.dirty());
        shell.reset();
        QCOMPARE(control->isChecked(), original);
        QVERIFY(!shell.dirty());
        control->setChecked(!original);
        QTRY_VERIFY(shell.canApply());
        shell.apply();
        QTRY_VERIFY(!shell.dirty());
        KConfig disk(directory + QStringLiteral("/kdeglobals"), KConfig::SimpleConfig);
        KConfigGroup settings(&disk, "QtQuickRendererSettings");
        QCOMPARE(settings.readEntry("ForceGlCoreProfile", original), !original);
        QVERIFY(QFileInfo::exists(directory + QStringLiteral("/kdeglobals")));
        shell.home();
        shell.open(QStringLiteral("kcm_qtquicksettings"));
        control = shell.findChild<QCheckBox *>(QStringLiteral("kcfg_ForceGlCoreProfile"));
        QVERIFY(control);
        QCOMPARE(control->isChecked(), !original);
        capture(shell, QStringLiteral("real-kcm-persisted"));
        control->setChecked(original);
        QTRY_VERIFY(shell.canApply());
        shell.apply();
        QTRY_VERIFY(!shell.dirty());
        disk.reparseConfiguration();
        QCOMPARE(settings.readEntry("ForceGlCoreProfile", original), original);
        shell.home();
    }
    void navigationAndPersistence() {
        Shell shell;
        QVERIFY(shell.qmlReady());
        QVERIFY(shell.modules().size() > 0);
        auto ids = Shell::discover();
        QVERIFY(std::any_of(ids.begin(), ids.end(), [](const auto &m) { return m.pluginId() == "ro_test_kcm"; }));
        shell.show();
        auto navigation = shell.findChildren<QQuickWidget *>().first();
        auto root = navigation->rootObject();
        QVERIFY(root);
        auto search = root->findChild<QObject *>(QStringLiteral("settingsSearch"));
        QVERIFY(search);
        search->setProperty("text", QStringLiteral("ro_test_kcm"));
        QTRY_COMPARE(root->property("filteredCount").toInt(), 1);
        QVERIFY(QMetaObject::invokeMethod(search, "accepted"));
        QCOMPARE(shell.currentId(), QStringLiteral("ro_test_kcm"));
        auto module = shell.findChild<KCModule *>();
        QVERIFY(module);
        QVERIFY(!shell.dirty());
        auto edit = shell.findChild<QPushButton *>(QStringLiteral("editTestValue"));
        QVERIFY(edit);
        edit->click();
        QVERIFY(shell.dirty());
        QVERIFY(shell.canApply());
        // Cancel navigation keeps the active module and pending edits.
        QTimer::singleShot(0, [] {
            auto dialog = qobject_cast<QMessageBox *>(QApplication::activeModalWidget());
            QVERIFY(dialog); dialog->done(QMessageBox::Cancel);
        });
        shell.home();
        QCOMPARE(shell.currentId(), QStringLiteral("ro_test_kcm"));
        shell.reset();
        QVERIFY(!shell.dirty());
        edit->click();
        shell.apply();
        QVERIFY(!shell.dirty());
        KConfig config(QStringLiteral("ro-shell-test-kcmrc"));
        QCOMPARE(KConfigGroup(&config, "Test").readEntry("value", 0), 1);
        shell.defaults();
        QVERIFY(shell.dirty());
        shell.reset();
        QVERIFY(!shell.dirty());
        // A missing authorization action must never persist pending settings.
        edit->click();
        auto auth = shell.findChild<QPushButton *>(QStringLiteral("requireTestAuthorization"));
        QVERIFY(auth);
        auth->click();
        shell.apply();
        QTRY_VERIFY_WITH_TIMEOUT(!shell.busy(), 10000);
        QVERIFY(shell.dirty());
        config.reparseConfiguration();
        QCOMPARE(KConfigGroup(&config, "Test").readEntry("value", 0), 1);
        shell.reset();
        shell.home();
        QCOMPARE(shell.currentId(), QString());
        QVERIFY(shell.canBack());
        shell.back();
        QCOMPARE(shell.currentId(), QStringLiteral("ro_test_kcm"));
        shell.forward();
        QCOMPARE(shell.currentId(), QString());
        shell.open(QStringLiteral("missing_module_for_test"));
        QVERIFY(!shell.error().isEmpty());
        QCOMPARE(shell.currentId(), QString());
        shell.open(QStringLiteral("ro_test_kcm"));
        shell.home();
        search->setProperty("text", QString());
        if (!qEnvironmentVariable("RO_SCREENSHOT_DIR").isEmpty()) {
            QTest::qWait(300);
            shell.grab().save(qEnvironmentVariable("RO_SCREENSHOT_DIR") + "/catalog.png");
        }
    }
    void realModuleLoad() {
        Shell shell;
        shell.show();
        const auto modules = Shell::discover();
        const QStringList safe{QStringLiteral("kcm_qtquicksettings"), QStringLiteral("kcm_formats"), QStringLiteral("kcm_fonts"), QStringLiteral("kcm_colors")};
        int opened = 0;
        for (const auto &id : safe) {
            if (std::none_of(modules.begin(), modules.end(), [&](const auto &m) { return m.pluginId() == id; })) continue;
            shell.open(id);
            QCOMPARE(shell.currentId(), id);
            QVERIFY2(shell.error().isEmpty(), qPrintable(shell.error()));
            QTest::qWait(500);
            QVERIFY(shell.qmlReady());
            QVERIFY(shell.findChild<KCModule *>());
            if (!qEnvironmentVariable("RO_SCREENSHOT_DIR").isEmpty()) shell.grab().save(qEnvironmentVariable("RO_SCREENSHOT_DIR") + "/" + id + ".png");
            ++opened;
            shell.home();
        }
        QVERIFY2(opened > 0, "Install one safe real KCM for the test gate");
    }
};
QTEST_MAIN(ShellTest)
#include "test_shell.moc"
