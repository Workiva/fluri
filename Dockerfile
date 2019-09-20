FROM google/dart:2.5 as dart2
FROM google/dart:1.24.3

WORKDIR /build/
ADD pubspec.yaml /build
COPY --from=dart2 /usr/lib/dart /usr/lib/dart2
RUN _PUB_TEST_SDK_VERSION=1.24.3 /usr/lib/dart2/bin/pub get --no-precompile
ARG BUILD_ARTIFACTS_BUILD=/build/pubspec.lock
FROM scratch
