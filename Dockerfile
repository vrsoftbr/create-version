FROM alpine:3.10

LABEL "com.github.actions.name"="create-version"
LABEL "com.github.actions.description"="Create version commit and tag"
LABEL "com.github.actions.icon"="check-square"
LABEL "com.github.actions.color"="yellow"

RUN apk add --no-cache \
    git \
    bash \
    curl \
    python3

COPY entrypoint.sh /entrypoint.sh

CMD ["sh", "entrypoint.sh"]