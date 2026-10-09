pragma Singleton
import QtQuick

QtObject {
    id: root

    property int navLevel: 0
    property int maxReachedLevel: 0

    property string level1Title: ""
    property string level2Title: ""

    property int activeCategoryIndex: -1
    property int activeSubCategoryIndex: -1
    property int accessIndex: 0

    property bool inDrillDownMode: true

    signal requestGoBack()
    signal requestGoForward()
    signal requestGoToLevel(int lvl)
    signal accessIndexChangedSignal(int newIndex)

    function goBack() {
        if (navLevel > 0) {
            goToLevel(navLevel - 1);
        }
    }

    function goForward() {
        if (navLevel < maxReachedLevel) {
            goToLevel(navLevel + 1);
        }
    }

    function goToLevel(lvl) {
        navLevel = lvl;
        if (lvl > maxReachedLevel) {
            maxReachedLevel = lvl;
        }
        requestGoToLevel(lvl);
    }

    function selectAccessPage(idx) {
        accessIndex = idx;
        accessIndexChangedSignal(idx);
    }
}
