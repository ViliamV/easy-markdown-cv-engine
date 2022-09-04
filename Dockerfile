FROM buildkite/puppeteer:v3.0.4
LABEL maintainer="viliam@valent.email"

RUN apt-get -y update
RUN apt-get -y install pandoc

WORKDIR /usr/app

COPY . /usr/app/

ENV CV_SOURCE src
ENV CV_OUTPUT output

ENTRYPOINT ["./build.sh"]
CMD ["wait"]
