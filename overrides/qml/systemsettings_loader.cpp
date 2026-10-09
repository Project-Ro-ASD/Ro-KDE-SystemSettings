#include <QQuickStyle>
#include <dlfcn.h>
#include <QResource>
#include <QFile>
#include <QDir>
#include <QSurfaceFormat>
#include <QQuickWindow>
#include <QFormLayout>
#include <QBoxLayout>
#include <QGridLayout>
#include <QGroupBox>
#include <QLabel>
#include <QTabWidget>
#include <QTimer>
#include <QWidget>
#include <QQuickWidget>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQmlContext>
#include <QUrl>
#include <QMetaProperty>
#include <cstring>
#include <cstdlib>

extern int qInitResources();
extern int qCleanupResources();

static void register_user_overrides() {
    qCleanupResources();
    qInitResources();
    static QString userRcc = QDir::homePath() + QStringLiteral("/.local/share/systemsettings/overrides.rcc");
    if (QFile::exists(userRcc)) {
        bool ok = QResource::registerResource(userRcc);
        fprintf(stderr, "[OVERRIDE] registered %s: %d\n", userRcc.toUtf8().constData(), ok);
    }
}

__attribute__((constructor)) static void loader_constructor() {
    fprintf(stderr, "[OVERRIDE] loader_constructor called\n");
    register_user_overrides();
}

static void configure_engine(QQmlEngine *engine) {
    if (!engine) return;
    QStringList paths = engine->importPathList();
    QString localQml = QDir::homePath() + QStringLiteral("/.local/lib/qt6/qml");
    if (!paths.contains(localQml)) {
        paths.prepend(localQml);
    }
    QString localShare = QDir::homePath() + QStringLiteral("/.local/share/systemsettings/qml");
    if (!paths.contains(localShare)) {
        paths.prepend(localShare);
    }
    engine->setImportPathList(paths);

    if (const char *testNav = getenv("RO_TEST_NAV")) {
        engine->rootContext()->setContextProperty(QStringLiteral("roTestNav"), QString::fromUtf8(testNav));
    } else {
        engine->rootContext()->setContextProperty(QStringLiteral("roTestNav"), QString());
    }
}

static QUrl redirect_url_if_needed(const QUrl &url, QQmlEngine *engine) {
    configure_engine(engine);
    QString urlStr = url.toString();
    if (urlStr == QStringLiteral("qrc:/qt/qml/org/kde/systemsettings/Main.qml")) {
        QString localMain = QDir::homePath() + QStringLiteral("/.local/share/systemsettings/qml/Main.qml");
        if (QFile::exists(localMain)) {
            return QUrl::fromLocalFile(localMain);
        }
    }
    if (urlStr == QStringLiteral("qrc:/qt/qml/org/kde/breeze/impl/ButtonBackground.qml")) {
        QString local = QDir::homePath() + QStringLiteral("/.local/lib/qt6/qml/org/kde/breeze/impl/ButtonBackground.qml");
        if (QFile::exists(local)) {
            return QUrl::fromLocalFile(local);
        }
    }
    if (urlStr == QStringLiteral("qrc:/qt/qml/org/kde/breeze/impl/ComboBoxBackground.qml")) {
        QString local = QDir::homePath() + QStringLiteral("/.local/lib/qt6/qml/org/kde/breeze/impl/ComboBoxBackground.qml");
        if (QFile::exists(local)) {
            return QUrl::fromLocalFile(local);
        }
    }
    return url;
}


// Hook QQuickWidget::setSource
extern "C" void _ZN12QQuickWidget9setSourceERK4QUrl(QQuickWidget *self, const QUrl &url) {
    static void (*real_setSource)(QQuickWidget*, const QUrl&) = nullptr;
    if (!real_setSource) {
        real_setSource = (void (*)(QQuickWidget*, const QUrl&))dlsym(RTLD_NEXT, "_ZN12QQuickWidget9setSourceERK4QUrl");
    }
    QUrl targetUrl = url;
    if (self) {
        targetUrl = redirect_url_if_needed(url, self->engine());
    }
    if (real_setSource) {
        real_setSource(self, targetUrl);
    }
}

// Hook QQmlComponent 4-argument constructor
extern "C" void _ZN13QQmlComponentC1EP10QQmlEngineRK4QUrlNS_15CompilationModeEP7QObject(
    QQmlComponent *self,
    QQmlEngine *engine,
    const QUrl &url,
    QQmlComponent::CompilationMode mode,
    QObject *parent)
{
    static void (*real_ctor)(QQmlComponent*, QQmlEngine*, const QUrl&, QQmlComponent::CompilationMode, QObject*) = nullptr;
    if (!real_ctor) {
        real_ctor = (void (*)(QQmlComponent*, QQmlEngine*, const QUrl&, QQmlComponent::CompilationMode, QObject*))
            dlsym(RTLD_NEXT, "_ZN13QQmlComponentC1EP10QQmlEngineRK4QUrlNS_15CompilationModeEP7QObject");
    }
    QUrl targetUrl = redirect_url_if_needed(url, engine);
    if (real_ctor) {
        real_ctor(self, engine, targetUrl, mode, parent);
    }
}

extern "C" void _ZN13QQmlComponentC2EP10QQmlEngineRK4QUrlNS_15CompilationModeEP7QObject(
    QQmlComponent *self,
    QQmlEngine *engine,
    const QUrl &url,
    QQmlComponent::CompilationMode mode,
    QObject *parent)
{
    _ZN13QQmlComponentC1EP10QQmlEngineRK4QUrlNS_15CompilationModeEP7QObject(self, engine, url, mode, parent);
}

// Hook QQmlComponent 3-argument constructor
extern "C" void _ZN13QQmlComponentC1EP10QQmlEngineRK4QUrlP7QObject(
    QQmlComponent *self,
    QQmlEngine *engine,
    const QUrl &url,
    QObject *parent)
{
    static void (*real_ctor)(QQmlComponent*, QQmlEngine*, const QUrl&, QObject*) = nullptr;
    if (!real_ctor) {
        real_ctor = (void (*)(QQmlComponent*, QQmlEngine*, const QUrl&, QObject*))
            dlsym(RTLD_NEXT, "_ZN13QQmlComponentC1EP10QQmlEngineRK4QUrlP7QObject");
    }
    QUrl targetUrl = redirect_url_if_needed(url, engine);
    if (real_ctor) {
        real_ctor(self, engine, targetUrl, parent);
    }
}

extern "C" void _ZN13QQmlComponentC2EP10QQmlEngineRK4QUrlP7QObject(
    QQmlComponent *self,
    QQmlEngine *engine,
    const QUrl &url,
    QObject *parent)
{
    _ZN13QQmlComponentC1EP10QQmlEngineRK4QUrlP7QObject(self, engine, url, parent);
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

// Hook QFormLayout::setFormAlignment to force left alignment
extern "C" void _ZN11QFormLayout16setFormAlignmentE6QFlagsIN2Qt13AlignmentFlagEE(QFormLayout *layout, Qt::Alignment alignment) {
    static void (*real_setFormAlignment)(QFormLayout*, Qt::Alignment) = nullptr;
    if (!real_setFormAlignment) {
        real_setFormAlignment = (void (*)(QFormLayout*, Qt::Alignment))dlsym(RTLD_NEXT, "_ZN11QFormLayout16setFormAlignmentE6QFlagsIN2Qt13AlignmentFlagEE");
    }
    Qt::Alignment newAlign = (alignment & ~(Qt::AlignHCenter | Qt::AlignRight)) | Qt::AlignLeft;
    if (real_setFormAlignment) {
        real_setFormAlignment(layout, newAlign);
    }
}

// Hook QFormLayout::setLabelAlignment to force left alignment
extern "C" void _ZN11QFormLayout17setLabelAlignmentE6QFlagsIN2Qt13AlignmentFlagEE(QFormLayout *layout, Qt::Alignment alignment) {
    static void (*real_setLabelAlignment)(QFormLayout*, Qt::Alignment) = nullptr;
    if (!real_setLabelAlignment) {
        real_setLabelAlignment = (void (*)(QFormLayout*, Qt::Alignment))dlsym(RTLD_NEXT, "_ZN11QFormLayout17setLabelAlignmentE6QFlagsIN2Qt13AlignmentFlagEE");
    }
    Qt::Alignment newAlign = (alignment & ~(Qt::AlignHCenter | Qt::AlignRight)) | Qt::AlignLeft;
    if (real_setLabelAlignment) {
        real_setLabelAlignment(layout, newAlign);
    }
}

// Hook QFormLayout constructor to default to left alignment with modern padding
extern "C" void _ZN11QFormLayoutC1EP7QWidget(QFormLayout *self, QWidget *parent) {
    static void (*real_ctor)(QFormLayout*, QWidget*) = nullptr;
    if (!real_ctor) {
        real_ctor = (void (*)(QFormLayout*, QWidget*))dlsym(RTLD_NEXT, "_ZN11QFormLayoutC1EP7QWidget");
    }
    if (real_ctor) {
        real_ctor(self, parent);
    }
    if (self) {
        self->setFormAlignment(Qt::AlignLeft | Qt::AlignTop);
        self->setLabelAlignment(Qt::AlignLeft | Qt::AlignVCenter);
        self->setContentsMargins(16, 14, 16, 14);
        self->setHorizontalSpacing(24);
        self->setVerticalSpacing(12);
    }
}


// Hook QGroupBox::setAlignment to force left alignment
extern "C" void _ZN9QGroupBox12setAlignmentEi(QGroupBox *self, int alignment) {
    static void (*real_setAlignment)(QGroupBox*, int) = nullptr;
    if (!real_setAlignment) {
        real_setAlignment = (void (*)(QGroupBox*, int))dlsym(RTLD_NEXT, "_ZN9QGroupBox12setAlignmentEi");
    }
    int newAlign = (alignment & ~Qt::AlignHCenter) | Qt::AlignLeft;
    if (real_setAlignment) {
        real_setAlignment(self, newAlign);
    }
}

// Hook QGroupBox constructor to default to left alignment
extern "C" void _ZN9QGroupBoxC1EP7QWidget(QGroupBox *self, QWidget *parent) {
    static void (*real_ctor)(QGroupBox*, QWidget*) = nullptr;
    if (!real_ctor) {
        real_ctor = (void (*)(QGroupBox*, QWidget*))dlsym(RTLD_NEXT, "_ZN9QGroupBoxC1EP7QWidget");
    }
    if (real_ctor) {
        real_ctor(self, parent);
    }
    if (self) {
        self->setAlignment(Qt::AlignLeft);
    }
}

// Hook QLabel::setAlignment to prevent centered text
extern "C" void _ZN6QLabel12setAlignmentE6QFlagsIN2Qt13AlignmentFlagEE(QLabel *self, Qt::Alignment alignment) {
    static void (*real_setAlignment)(QLabel*, Qt::Alignment) = nullptr;
    if (!real_setAlignment) {
        real_setAlignment = (void (*)(QLabel*, Qt::Alignment))dlsym(RTLD_NEXT, "_ZN6QLabel12setAlignmentE6QFlagsIN2Qt13AlignmentFlagEE");
    }
    Qt::Alignment newAlign = alignment;
    if (newAlign & Qt::AlignHCenter) {
        newAlign = (newAlign & ~Qt::AlignHCenter) | Qt::AlignLeft;
    }
    if (real_setAlignment) {
        real_setAlignment(self, newAlign);
    }
}

// Hook QBoxLayout::addWidget to prevent centered widget placement
extern "C" void _ZN10QBoxLayout9addWidgetEP7QWidgeti6QFlagsIN2Qt13AlignmentFlagEE(QBoxLayout *self, QWidget *widget, int stretch, Qt::Alignment alignment) {
    static void (*real_addWidget)(QBoxLayout*, QWidget*, int, Qt::Alignment) = nullptr;
    if (!real_addWidget) {
        real_addWidget = (void (*)(QBoxLayout*, QWidget*, int, Qt::Alignment))dlsym(RTLD_NEXT, "_ZN10QBoxLayout9addWidgetEP7QWidgeti6QFlagsIN2Qt13AlignmentFlagEE");
    }
    Qt::Alignment newAlign = alignment;
    if (newAlign & Qt::AlignHCenter) {
        newAlign = (newAlign & ~Qt::AlignHCenter) | Qt::AlignLeft;
    }
    if (real_addWidget) {
        real_addWidget(self, widget, stretch, newAlign);
    }
}

// Hook QGridLayout::addWidget to prevent centered placement
extern "C" void _ZN11QGridLayout9addWidgetEP7QWidgetiiii6QFlagsIN2Qt13AlignmentFlagEE(QGridLayout *self, QWidget *widget, int fromRow, int fromColumn, int rowSpan, int columnSpan, Qt::Alignment alignment) {
    static void (*real_addWidget)(QGridLayout*, QWidget*, int, int, int, int, Qt::Alignment) = nullptr;
    if (!real_addWidget) {
        real_addWidget = (void (*)(QGridLayout*, QWidget*, int, int, int, int, Qt::Alignment))dlsym(RTLD_NEXT, "_ZN11QGridLayout9addWidgetEP7QWidgetiiii6QFlagsIN2Qt13AlignmentFlagEE");
    }
    Qt::Alignment newAlign = alignment;
    if (newAlign & Qt::AlignHCenter) {
        newAlign = (newAlign & ~Qt::AlignHCenter) | Qt::AlignLeft;
    }
    if (real_addWidget) {
        real_addWidget(self, widget, fromRow, fromColumn, rowSpan, columnSpan, newAlign);
    }
}

// Hook QTabWidget::addTab to support automated tab testing, margins, and card styling
extern "C" int _ZN10QTabWidget6addTabEP7QWidgetRK7QString(QTabWidget *self, QWidget *page, const QString &label) {
    static int (*real_addTab)(QTabWidget*, QWidget*, const QString&) = nullptr;
    if (!real_addTab) {
        real_addTab = (int (*)(QTabWidget*, QWidget*, const QString&))dlsym(RTLD_NEXT, "_ZN10QTabWidget6addTabEP7QWidgetRK7QString");
    }
    if (page) {
        auto groupBoxes = page->findChildren<QGroupBox*>();
        if (groupBoxes.isEmpty()) {
            page->setProperty("singleCard", true);
            page->setAttribute(Qt::WA_StyledBackground, true);
        }
        if (page->layout()) {
            page->layout()->setContentsMargins(20, 16, 20, 16);
        }
    }

    int idx = real_addTab ? real_addTab(self, page, label) : -1;
    const char *selTabEnv = getenv("SS_SELECT_TAB");
    if (selTabEnv && self) {
        int targetIdx = atoi(selTabEnv);
        QTimer::singleShot(200, [self, targetIdx]() {
            if (targetIdx >= 0 && targetIdx < self->count()) {
                self->setCurrentIndex(targetIdx);
            }
        });
    }
    return idx;
}

// Hook Kirigami::Platform::Units qt_metacall & cornerRadius to make all QML buttons, comboboxes, and controls pill-shaped (16px)
extern "C" int _ZN8Kirigami8Platform5Units11qt_metacallEN11QMetaObject4CallEiPPv(
    QObject *self, QMetaObject::Call c, int id, void **a)
{
    static int (*real_metacall)(QObject*, QMetaObject::Call, int, void**) = nullptr;
    if (!real_metacall) {
        real_metacall = (int (*)(QObject*, QMetaObject::Call, int, void**))
            dlsym(RTLD_NEXT, "_ZN8Kirigami8Platform5Units11qt_metacallEN11QMetaObject4CallEiPPv");
    }
    int res = real_metacall ? real_metacall(self, c, id, a) : -1;
    if (c == QMetaObject::ReadProperty && self && a && a[0]) {
        const QMetaObject *mo = self->metaObject();
        if (mo) {
            int propCount = mo->propertyCount();
            if (id >= 0 && id < propCount) {
                const char *propName = mo->property(id).name();
                if (propName && strcmp(propName, "cornerRadius") == 0) {
                    *reinterpret_cast<double*>(a[0]) = 16.0;
                }
            }
        }
    }
    return res;
}

extern "C" double _ZNK8Kirigami8Platform5Units12cornerRadiusEv(void *self) {
    return 16.0;
}

extern "C" void _ZN11QQuickStyle8setStyleERK7QString(const QString &style) {
    static void (*real_setStyle)(const QString&) = nullptr;
    if (!real_setStyle) {
        real_setStyle = (void (*)(const QString&))dlsym(RTLD_NEXT, "_ZN11QQuickStyle8setStyleERK7QString");
    }
    static const QString breezeStyle = QStringLiteral("org.kde.breeze");
    if (real_setStyle) {
        real_setStyle(breezeStyle);
    }
}

__attribute__((constructor))
static void ro_kde_systemsettings_init() {
    QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
    fmt.setAlphaBufferSize(0);
    QSurfaceFormat::setDefaultFormat(fmt);
    QQuickWindow::setDefaultAlphaBuffer(false);

    QQuickStyle::setStyle(QStringLiteral("org.kde.breeze"));

    register_user_overrides();
}


