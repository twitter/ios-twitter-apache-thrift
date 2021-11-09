git clone https://github.com/DoccZz/docc2html.git

mkdir -p ./.build/docs/
xcodebuild docbuild -scheme TwitterApacheThrift -derivedDataPath ./.build/docs/TwitterApacheThrift -destination "platform=iOS Simulator,OS=13.5,name=iPhone 8"

BUNDLE_PATH=$(find ./.build/docs/TwitterApacheThrift -type d -name '*.doccarchive')
echo $BUNDLE_PATH

cd docc2html
swift run docc2html --force ../"$BUNDLE_PATH" ../docs

rm -rf ../docc2html
