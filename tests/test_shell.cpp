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
#include <KConfig>
#include <KConfigGroup>

class ShellTest : public QObject {
    Q_OBJECT
private Q_SLOTS:
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
