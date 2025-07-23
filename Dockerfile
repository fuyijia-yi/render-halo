FROM eclipse-temurin:23-jre

WORKDIR /opt/halo

ENV TZ=Asia/Shanghai
ENV JVM_OPTS="-Xmx256m -Xms256m"

RUN apt-get update && \
    apt-get install -y wget python3 python3-venv python3-pip tar gzip jq curl  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sL https://api.github.com/repos/halo-dev/halo/releases/latest | \
    jq -r '.assets[] | select(.name | test(".jar$")) | .browser_download_url' | \
    xargs curl -L -o halo.jar

RUN mkdir -p ~/.halo2

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --no-cache-dir requests webdavclient3

COPY cfgo sync_data.sh /opt/halo/
RUN chmod +x /opt/halo/sync_data.sh /opt/halo/cfgo

EXPOSE 8090

CMD ["/bin/sh", "-c", "/opt/halo/cfgo tunnel --no-autoupdate run --token $CF_TOKEN & bash /opt/halo/sync_data.sh & sleep 30 && java ${JVM_OPTS} -jar /opt/halo/halo.jar"]
