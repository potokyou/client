import QtQuick

Text {
    lineHeight: 16 + LanguageModel.getLineHeightAppend()
    lineHeightMode: Text.FixedHeight

    color: "#141414"
    font.pixelSize: 13
    font.weight: 400
    font.family: "PT Root UI VF"
    font.letterSpacing: 0.02

    wrapMode: Text.Wrap
}
