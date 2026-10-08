#include <dlfcn.h>
#include <QResource>
#include <QFile>
#include <QDir>
#include <QSurfaceFormat>
#include <QQuickWindow>
#include <cstring>

extern int qInitResources();
extern int qCleanupResources();

static void register_user_overrides() {
    qCleanupResources();
    qInitResources();
    static QString userRcc = QDir::homePath() + QStringLiteral("/.local/share/systemsettings/overrides.rcc");
    if (QFile::exists(userRcc)) {
        QResource::registerResource(userRcc);
    }
}

extern "C" void* dlopen(const char* filename, int flags) {
    static void* (*real_dlopen)(const char*, int) = nullptr;
    if (!real_dlopen) {
        real_dlopen = (void* (*)(const char*, int))dlsym(RTLD_NEXT, "dlopen");
    }
    void* handle = real_dlopen(filename, flags);
    if (handle) {
        register_user_overrides();
    }
    return handle;
}

__attribute__((constructor))
static void ro_kde_systemsettings_init() {
    QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
    fmt.setAlphaBufferSize(0);
    QSurfaceFormat::setDefaultFormat(fmt);
    QQuickWindow::setDefaultAlphaBuffer(false);

    register_user_overrides();
}
