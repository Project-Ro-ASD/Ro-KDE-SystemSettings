# Ro-KDE-SystemSettings XDG search path integration
if [ -d "/usr/share/ro-kde-systemsettings" ]; then
    case ":${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:" in
        *:/usr/share/ro-kde-systemsettings:*) ;;
        *) export XDG_DATA_DIRS="/usr/share/ro-kde-systemsettings:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" ;;
    esac
fi
