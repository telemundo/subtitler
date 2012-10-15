VERSION=${1-"dev"}

rm -rf "${BUILT_PRODUCTS_DIR}/tmp/Subtitler.app"
cp -r "${BUILT_PRODUCTS_DIR}/Subtitler.app" "${BUILT_PRODUCTS_DIR}/tmp/"
rm -rf "${BUILT_PRODUCTS_DIR}/subtitler-${VERSION}.dmg"

create-dmg \
--volname Subtitler \
--volicon "${SOURCE_ROOT}/assets/subtitler.icns" \
--background "${SOURCE_ROOT}/assets/background.png" \
--window-size 700 400 \
--icon-size 128 \
--icon Subtitler.app 151 190 \
--app-drop-link 550 190 \
"${BUILT_PRODUCTS_DIR}/subtitler-${VERSION}.dmg" \
"${BUILT_PRODUCTS_DIR}/tmp/"
