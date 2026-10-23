// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-or-later
#include <KCModule>
#include <KConfig>
#include <KConfigGroup>
#include <KPluginFactory>
#include <QPushButton>
#include <QVBoxLayout>
class TestKCM : public KCModule {
    Q_OBJECT
public:
    TestKCM(QObject *parent, const KPluginMetaData &data, const QVariantList &) : KCModule(qobject_cast<QWidget *>(parent), data) {
        setButtons(Apply | Default);
        auto layout = new QVBoxLayout(widget());
        auto edit = new QPushButton(QStringLiteral("Increment isolated test value"), widget());
        edit->setObjectName(QStringLiteral("editTestValue"));
        layout->addWidget(edit);
        connect(edit, &QPushButton::clicked, this, [this] { ++value; update(); });
        auto auth = new QPushButton(QStringLiteral("Require unavailable test authorization"), widget());
        auth->setObjectName(QStringLiteral("requireTestAuthorization"));
        layout->addWidget(auth);
        connect(auth, &QPushButton::clicked, this, [this] { setAuthActionName(QStringLiteral("org.ro.systemsettings.test.unavailable")); });
    }
    void load() override { config.reparseConfiguration(); value = KConfigGroup(&config, "Test").readEntry("value", 0); saved = value; update(); }
    void save() override { KConfigGroup(&config, "Test").writeEntry("value", value); config.sync(); saved = value; update(); }
    void defaults() override { value = 0; update(); }
private:
    void update() { setNeedsSave(value != saved); setRepresentsDefaults(value == 0); }
    KConfig config{QStringLiteral("ro-shell-test-kcmrc")};
    int value = 0, saved = 0;
};
K_PLUGIN_CLASS_WITH_JSON(TestKCM, "test_kcm.json")
#include "test_kcm.moc"
