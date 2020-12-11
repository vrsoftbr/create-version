FROM alpine:3.10

LABEL "com.github.actions.name"="create-version"
LABEL "com.github.actions.description"="Create version commit and tag"
LABEL "com.github.actions.icon"="check-square"
LABEL "com.github.actions.color"="yellow"

RUN apk add --no-cache \
    openjdk11 \
    git \
    bash \
    curl \
    python3 \
    py3-pip

COPY create_tag.py /create_tag.py
COPY entrypoint.sh /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]