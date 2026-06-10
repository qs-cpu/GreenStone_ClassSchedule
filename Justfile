@init:
  flutter clean && flutter pub get
  cd app && bun install

@start:
  #!/usr/bin/env bash
  cd app && bun run dev & FPID=$!
  flutter run -d web-server &
  trap "kill $FPID 2>/dev/null" EXIT
  wait

@api:
  cd app && bun run dev

@web:
  flutter run -d web-server

@admin:
  cd app && bun run src/seed-admin.ts

@build-web:
  flutter build web

@build-apk:
  flutter build apk --release

@build-apk-url api_url:
  flutter build apk --release --dart-define=API_URL="{{api_url}}"

@analyze:
  flutter analyze

@fmt:
  dart format .

@test:
  flutter test
  cd app && bun test
