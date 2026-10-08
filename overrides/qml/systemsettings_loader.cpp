#include <dlfcn.h>
#include <QResource>
#include <QFile>
#include <QDir>
#include <cstring>

static void register_user_overrides() {
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
    if (handle && filename && (strstr(filename, "kcm_") || strstr(filename, "plasma") || strstr(filename, "systemsettings"))) {
        register_user_overrides();
    }
    return handle;
}

__attribute__((constructor))
static void ro_kde_systemsettings_init() {
    register_user_overrides();
}
