#include <QResource>
#include <QFile>
#include <QDir>

__attribute__((constructor))
static void ro_kde_systemsettings_init() {
    QString userRcc = QDir::homePath() + QStringLiteral("/.local/share/systemsettings/overrides.rcc");
    if (QFile::exists(userRcc)) {
        QResource::registerResource(userRcc);
    }
}
