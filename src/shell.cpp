// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-or-later
// Original Ro shell. Uses installed public KF6 headers; no System Settings code is embedded.
#include "shell.h"
#include <KAuthorized>
#include <KConfigGroup>
#include <KDesktopFile>
#include <KCModule>
#include <KCModuleLoader>
#include <KAuth/Action>
#include <KAuth/ExecuteJob>
#include <QCloseEvent>
#include <QDir>
#include <QGuiApplication>
#include <QHBoxLayout>
#include <QJsonObject>
#include <QKeySequence>
#include <QLocale>
#include <QMessageBox>
#include <QProcess>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickWidget>
#include <QScrollArea>
#include <QSet>
#include <QShortcut>
#include <QStandardPaths>
#include <algorithm>

QList<KPluginMetaData> Shell::discover()
{
    QList<KPluginMetaData> result;
    QSet<QString> seen;
    for (const auto &space : {"plasma/kcms", "plasma/kcms/systemsettings", "plasma/kcms/systemsettings_qwidgets"}) {
        for (const auto &data : KPluginMetaData::findPlugins(QString::fromLatin1(space))) {
            const auto platforms = data.value(QStringLiteral("X-KDE-OnlyShowOnQtPlatforms"), QStringList());
            const bool platformOk = platforms.isEmpty() || std::any_of(platforms.begin(), platforms.end(), [](const QString &p) {
                return QGuiApplication::platformName().startsWith(p);
            });
            const auto factors = data.formFactors();
            if (data.isHidden() || !platformOk || (!factors.isEmpty() && !factors.contains(QStringLiteral("desktop")) && !factors.contains(QStringLiteral("all")))
                || seen.contains(data.pluginId()) || !KAuthorized::authorizeControlModule(data.pluginId())) continue;
            seen.insert(data.pluginId());
            result.append(data);
        }
    }
    std::sort(result.begin(), result.end(), [](const auto &a, const auto &b) { return a.pluginId() < b.pluginId(); });
    return result;
}

Shell::Shell(QWidget *parent) : QWidget(parent), m_metadata(discover()), m_engine(std::make_shared<QQmlEngine>())
{
    setWindowTitle(QStringLiteral("Ro System Settings"));
    setWindowIcon(QIcon::fromTheme(QStringLiteral("preferences-system")));
    resize(1120, 760);
    setMinimumSize(760, 520);
    // Read installed category metadata without overriding stock data paths.
    QMap<QString, QVariantMap> categoryMap;
    for (const QString &dir : QStandardPaths::locateAll(QStandardPaths::GenericDataLocation,
            QStringLiteral("systemsettings/categories"), QStandardPaths::LocateDirectory)) {
        for (const QString &file : QDir(dir).entryList({QStringLiteral("*.desktop")}, QDir::Files)) {
            KDesktopFile desktop(dir + QLatin1Char('/') + file);
            const auto group = desktop.desktopGroup();
            const auto id = group.readEntry("X-KDE-System-Settings-Category");
            if (id.isEmpty() || categoryMap.contains(id)) continue;
            categoryMap.insert(id, {{"id", id}, {"name", desktop.readName()},
                {"parent", group.readEntry("X-KDE-System-Settings-Parent-Category")}});
        }
    }
    const QString other = turkish() ? QStringLiteral("Diğer") : QStringLiteral("Other");
    categoryMap.insert(QStringLiteral("other"), {{"id", "other"}, {"name", other}, {"parent", ""}});
    for (const auto &data : m_metadata) {
        QString category = data.value(QStringLiteral("X-KDE-System-Settings-Parent-Category-V2"));
        if (category.isEmpty()) category = data.value(QStringLiteral("X-KDE-System-Settings-Parent-Category"));
        if (category == QStringLiteral("rootcategory") || !categoryMap.contains(category)) category = QStringLiteral("other");
        QStringList names;
        QSet<QString> visited;
        QString top = category;
        for (QString cursor = category; categoryMap.contains(cursor) && !visited.contains(cursor); ) {
            visited.insert(cursor);
            const auto node = categoryMap.value(cursor);
            if (cursor != QStringLiteral("rootcategory")) { names.prepend(node.value("name").toString()); top = cursor; }
            cursor = node.value("parent").toString();
        }
        m_modules.append(QVariantMap{{"id", data.pluginId()}, {"name", data.name()}, {"description", data.description()},
            {"category", category}, {"topCategory", top}, {"path", names.join(QStringLiteral(" / "))},
            {"keywords", data.value(QStringLiteral("X-KDE-Keywords"))}});
    }
    for (auto it = categoryMap.cbegin(); it != categoryMap.cend(); ++it) m_categories.append(it.value());
    auto layout = new QHBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(0);
    m_navigation = new QQuickWidget(this);
    makeView(m_navigation, QStringLiteral("Main"));
    layout->addWidget(m_navigation, 1);
    m_pane = new QWidget(this);
    auto paneLayout = new QVBoxLayout(m_pane);
    paneLayout->setContentsMargins(0, 0, 0, 0);
    m_header = new QQuickWidget(m_pane);
    m_header->setFixedHeight(150);
    makeView(m_header, QStringLiteral("ModuleHeader"));
    paneLayout->addWidget(m_header);
    m_scroll = new QScrollArea(m_pane);
    m_scroll->setWidgetResizable(true);
    m_scroll->setFrameShape(QFrame::NoFrame);
    m_scroll->setAccessibleName(turkish() ? QStringLiteral("Ayar sayfası") : QStringLiteral("Settings page"));
    paneLayout->addWidget(m_scroll, 1);
    layout->addWidget(m_pane, 3);
    m_pane->hide();
    new QShortcut(QKeySequence(Qt::ALT | Qt::Key_Left), this, [this] { back(); });
    new QShortcut(QKeySequence(Qt::ALT | Qt::Key_Right), this, [this] { forward(); });
    if (m_metadata.isEmpty()) setError(turkish() ? QStringLiteral("Uyumlu KDE ayar modülü bulunamadı. KDE Sistem Ayarları'nı açabilirsiniz.")
        : QStringLiteral("No compatible KDE settings modules found. You can open KDE System Settings."));
}

void Shell::makeView(QQuickWidget *view, const QString &file)
{
    view->setFocusPolicy(Qt::StrongFocus);
    view->setResizeMode(QQuickWidget::SizeRootObjectToView);
    view->rootContext()->setContextProperty(QStringLiteral("shell"), this);
    view->setSource(QUrl(QStringLiteral("qrc:/ro/org/ro/systemsettings/%1.qml").arg(file)));
}
QVariantList Shell::tabs() const
{
    QVariantList result;
    QSet<QString> seen;
    // History tabs recreate pages on demand; they do not retain KCM objects.
    for (const auto &id : m_history) {
        if (id.isEmpty() || seen.contains(id)) continue;
        const auto it = std::find_if(m_metadata.cbegin(), m_metadata.cend(), [&](const auto &m) { return m.pluginId() == id; });
        if (it != m_metadata.cend()) { result.append(QVariantMap{{"id", id}, {"name", it->name()}}); seen.insert(id); }
    }
    return result;
}
bool Shell::qmlReady() const { return m_navigation->status() == QQuickWidget::Ready && m_header->status() == QQuickWidget::Ready; }
Shell::~Shell()
{
    unload();
    // Destroy QML roots while their context object and property storage are alive.
    delete m_header;
    delete m_navigation;
}
bool Shell::turkish() const { return QLocale().language() == QLocale::Turkish; }
QString Shell::title() const { return m_module ? m_module->name() : QStringLiteral("Ro System Settings"); }
bool Shell::dirty() const { return m_module && m_module->needsSave(); }
bool Shell::canApply() const { return m_module && (m_module->buttons() & KCModule::Apply) && dirty() && !m_busy; }
bool Shell::canDefault() const { return m_module && (m_module->buttons() & KCModule::Default) && !m_module->representsDefaults() && !m_busy; }
void Shell::setError(const QString &message) { m_error = message; Q_EMIT stateChanged(); }
void Shell::unload()
{
    // Some KCM destructors access their widgets; destroy module before widget/engine.
    delete m_module;
    m_module = nullptr;
    delete m_scroll->takeWidget();
}
bool Shell::resolveChanges()
{
    if (m_busy) return false;
    if (!dirty()) return true;
    const auto answer = QMessageBox::warning(this, turkish() ? QStringLiteral("Kaydedilmemiş değişiklikler") : QStringLiteral("Unsaved changes"),
        turkish() ? QStringLiteral("Değişiklikleri uygulayın veya vazgeçin. Uyguladıktan sonra yeniden gezinin.")
                  : QStringLiteral("Apply or discard your changes. After applying, navigate again."),
        QMessageBox::Apply | QMessageBox::Discard | QMessageBox::Cancel, QMessageBox::Cancel);
    if (answer == QMessageBox::Apply) { apply(); return false; }
    if (answer == QMessageBox::Discard) { reset(); return true; }
    return false;
}
void Shell::navigate(const QString &id, int historyIndex)
{
    if (id == m_current || !resolveChanges()) return;
    auto it = std::find_if(m_metadata.cbegin(), m_metadata.cend(), [&](const auto &m) { return m.pluginId() == id; });
    if (!id.isEmpty() && (it == m_metadata.cend() || !KAuthorized::authorizeControlModule(id))) {
        setError(turkish() ? QStringLiteral("Modül kullanılamıyor veya erişim kısıtlı.") : QStringLiteral("Module unavailable or access restricted.")); return;
    }
    unload();
    m_error.clear();
    m_current = id;
    if (!id.isEmpty()) {
        // KCModule may create a layout on its parent; QScrollArea already owns one.
        // Give every selected module a fresh plain host, owned by the scroll area.
        auto host = new QWidget(m_scroll);
        m_scroll->setWidget(host);
        m_module = KCModuleLoader::loadModule(*it, host, {}, m_engine);
        if (!m_module) { m_current.clear(); setError(QStringLiteral("KCM loader failed. Open KDE System Settings.")); }
        else {
            QWidget *content = m_module->widget();
            if (!host->layout()) {
                auto contentLayout = new QVBoxLayout(host);
                contentLayout->setContentsMargins(0, 0, 0, 0);
            }
            if (host->layout()->indexOf(content) < 0) host->layout()->addWidget(content);
            host->setFocusProxy(content);
            for (auto signal : {&KCModule::needsSaveChanged, &KCModule::representsDefaultsChanged, &KCModule::buttonsChanged, &KCModule::authActionNameChanged})
                connect(m_module, signal, this, &Shell::stateChanged);
            m_module->load();
            if (!m_module->metaData().isValid())
                setError(turkish() ? QStringLiteral("KDE modülü yüklenemedi. KDE Sistem Ayarları'nı açabilirsiniz.")
                                  : QStringLiteral("KDE module could not load. You can open KDE System Settings."));
        }
    }
    m_pane->setVisible(m_module != nullptr);
    m_navigation->setMaximumWidth(m_module ? 290 : QWIDGETSIZE_MAX);
    if (historyIndex >= 0) m_historyIndex = historyIndex;
    else {
        m_history = m_history.mid(0, m_historyIndex + 1);
        m_history.append(m_current);
        m_historyIndex = m_history.size() - 1;
    }
    Q_EMIT stateChanged();
    Q_EMIT moduleOpened(m_current);
}
void Shell::open(const QString &id) { navigate(id); }
void Shell::home() { navigate(QString()); }
void Shell::back() { if (canBack()) navigate(m_history.at(m_historyIndex - 1), m_historyIndex - 1); }
void Shell::forward() { if (canForward()) navigate(m_history.at(m_historyIndex + 1), m_historyIndex + 1); }
void Shell::apply()
{
    if (!canApply()) return;
    if (!m_module->needsAuthorization()) { m_module->save(); Q_EMIT stateChanged(); return; }
    KAuth::Action action(m_module->authActionName());
    if (!action.isValid()) { setError(QStringLiteral("KDE authorization action unavailable.")); return; }
    action.setParentWindow(window()->windowHandle());
    m_busy = true;
    Q_EMIT stateChanged();
    auto job = action.execute(KAuth::Action::AuthorizeOnlyMode);
    connect(job, &KJob::result, this, [this, job] {
        m_busy = false;
        // Never call save after a rejected/cancelled authorization.
        if (job->error() == 0 && m_module) m_module->save();
        else setError(turkish() ? QStringLiteral("Yetkilendirme tamamlanmadı; değişiklikler kaydedilmedi.")
                               : QStringLiteral("Authorization did not complete; changes were not saved."));
        Q_EMIT stateChanged();
    });
    job->start();
}
void Shell::reset() { if (m_module && !m_busy) { m_module->load(); Q_EMIT stateChanged(); } }
void Shell::defaults() { if (canDefault()) { m_module->defaults(); Q_EMIT stateChanged(); } }
void Shell::stock() { QProcess::startDetached(QStringLiteral("/usr/bin/systemsettings"), {}); }
void Shell::closeEvent(QCloseEvent *event) { if (resolveChanges()) event->accept(); else event->ignore(); }
