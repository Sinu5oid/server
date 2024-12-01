ARG GO_VERSION=1.23.2
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION} AS build
LABEL org.opencontainers.image.source=https://github.com/sinu5oid/server
WORKDIR /src

RUN --mount=type=cache,target=/go/pkg/mod/ \
  --mount=type=bind,source=go.sum,target=go.sum \
  --mount=type=bind,source=go.mod,target=go.mod \
  go mod download -x

ARG TARGETOS
ARG TARGETARCH

COPY . /src

RUN --mount=type=cache,target=/go/pkg/mod/ \
  CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /bin/server .

FROM alpine:latest AS final
LABEL org.opencontainers.image.source=https://github.com/sinu5oid/server
RUN --mount=type=cache,target=/var/cache/apk \
  apk --update add \
  ca-certificates \
  tzdata \
  curl \
  && \
  update-ca-certificates
ARG UID=10001
RUN adduser \
  --disabled-password \
  --gecos "" \
  --home "/nonexistent" \
  --shell "/sbin/nologin" \
  --no-create-home \
  --uid "${UID}" \
  appuser
USER appuser
COPY --from=build /bin/server /bin/
EXPOSE 8080
ENTRYPOINT [ "/bin/server" ]
