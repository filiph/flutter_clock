# fortune_clock

## Building for the web

To build this for the web, go to the root directory of the repo and run:

    flutter pub global run peanut -d fortune_clock/web/

(This assumes you have a version of Flutter that supports web compilation, and that you have
installed peanut by running `flutter pub global activate peanut`.)

If the compilation fails with `No .dart_tool/package_config.json file found`, run the following
just before running `peanut`:

    cd fortune_clock && flutter packages get && cd -
