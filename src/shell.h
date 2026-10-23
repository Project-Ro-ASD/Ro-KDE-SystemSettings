// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-or-later
#pragma once
#include <QWidget>
#include <QVariantList>
#include <KPluginMetaData>
#include <memory>
class KCModule;
class QQuickWidget;
class QScrollArea;
class QQmlEngine;
class Shell : public QWidget {
    Q_OBJECT
    Q_PROPERTY(QVariantList modules READ modules CONSTANT)
    Q_PROPERTY(QVariantList tabs READ tabs NOTIFY stateChanged)
    Q_PROPERTY(QVariantList categories READ categories CONSTANT)
    Q_PROPERTY(QString currentId READ currentId NOTIFY stateChanged)
    Q_PROPERTY(QString title READ title NOTIFY stateChanged)
    Q_PROPERTY(QString error READ error NOTIFY stateChanged)
    Q_PROPERTY(bool dirty READ dirty NOTIFY stateChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY stateChanged)
    Q_PROPERTY(bool canApply READ canApply NOTIFY stateChanged)
    Q_PROPERTY(bool canDefault READ canDefault NOTIFY stateChanged)
    Q_PROPERTY(bool canBack READ canBack NOTIFY stateChanged)
    Q_PROPERTY(bool canForward READ canForward NOTIFY stateChanged)
    Q_PROPERTY(bool turkish READ turkish CONSTANT)
public:
    explicit Shell(QWidget *parent = nullptr);
    ~Shell() override;
    QVariantList tabs() const;
    QVariantList modules() const { return m_modules; }
    QVariantList categories() const { return m_categories; }
    QString currentId() const { return m_current; }
    QString title() const;
    QString error() const { return m_error; }
    bool dirty() const;
    bool busy() const { return m_busy; }
    bool canApply() const;
    bool canDefault() const;
    bool canBack() const { return m_historyIndex > 0; }
    bool canForward() const { return m_historyIndex + 1 < m_history.size(); }
    bool turkish() const;
    Q_INVOKABLE void open(const QString &id);
    Q_INVOKABLE void home();
    Q_INVOKABLE void back();
    Q_INVOKABLE void forward();
    Q_INVOKABLE void apply();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void defaults();
    Q_INVOKABLE void stock();
    // Metadata-only diagnostics never instantiate KCM plugins.
    static QList<KPluginMetaData> discover();
    bool qmlReady() const;
Q_SIGNALS:
    void stateChanged();
    void moduleOpened(const QString &id);
protected:
    void closeEvent(QCloseEvent *event) override;
private:
    void navigate(const QString &id, int historyIndex = -1);
    bool resolveChanges();
    void unload();
    void setError(const QString &message);
    void makeView(QQuickWidget *view, const QString &file);
    QList<KPluginMetaData> m_metadata;
    QVariantList m_modules, m_categories;
    QString m_current, m_error;
    QStringList m_history{QString()};
    int m_historyIndex = 0;
    bool m_busy = false;
    KCModule *m_module = nullptr;
    std::shared_ptr<QQmlEngine> m_engine;
    QQuickWidget *m_navigation, *m_header;
    QWidget *m_pane;
    QScrollArea *m_scroll;
};
