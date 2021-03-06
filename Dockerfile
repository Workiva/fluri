FROM google/dart:2
WORKDIR /build/
ADD pubspec.yaml .
RUN dart pub get
FROM scratch
