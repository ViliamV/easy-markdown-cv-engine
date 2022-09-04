FROM buildkite/puppeteer:10.0.0
LABEL maintainer="viliam@valent.email"

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get -y update
RUN apt-get -y install pandoc

WORKDIR /usr/app

COPY . /usr/app/

ENV CV_SOURCE src
ENV CV_OUTPUT output

ENTRYPOINT ["./build.sh"]
CMD ["wait"]
