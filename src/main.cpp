// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-or-later
#include "shell.h"
#include <QApplication>
#include <QCommandLineParser>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTextStream>
#include <QTimer>
#include <KLocalizedString>
int main(int argc, char **argv)
{
    QApplication app(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("ro-systemsettings"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("ro-asd.org"));
    QCoreApplication::setApplicationVersion(QStringLiteral(RO_VERSION));
    QApplication::setDesktopFileName(QStringLiteral("ro-systemsettings"));
    KLocalizedString::setApplicationDomain("ro-systemsettings");
    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Independent Ro shell for KDE settings modules"));
    parser.addHelpOption(); parser.addVersionOption();
    parser.addOption({QStringLiteral("list"), QStringLiteral("List discovered module metadata as JSON; do not load plugins")});
    parser.addOption({QStringLiteral("quit-after"), QStringLiteral("Exit after milliseconds (isolated smoke tests)"), QStringLiteral("ms")});
    parser.addPositionalArgument(QStringLiteral("module"), QStringLiteral("Installed KCM plugin ID"), QStringLiteral("[module]"));
    parser.process(app);
    if (parser.isSet(QStringLiteral("list"))) {
        QJsonArray modules;
        for (const auto &m : Shell::discover()) modules.append(QJsonObject{{"id", m.pluginId()}, {"name", m.name()}, {"file", m.fileName()}});
        QTextStream(stdout) << QJsonDocument(modules).toJson(); return 0;
    }
    Shell shell;
    if (!shell.qmlReady()) { QTextStream(stderr) << "Ro QML failed to load. Run /usr/bin/systemsettings.\n"; return 2; }
    shell.show();
    if (!parser.positionalArguments().isEmpty()) shell.open(parser.positionalArguments().first());
    if (parser.isSet(QStringLiteral("quit-after"))) {
        bool ok = false; int ms = parser.value(QStringLiteral("quit-after")).toInt(&ok);
        if (!ok || ms < 1) return 2;
        QTimer::singleShot(ms, &app, [&app, &shell] { app.exit(shell.error().isEmpty() ? 0 : 3); });
    }
    return app.exec();
}
