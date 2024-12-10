FROM alpine AS build
RUN apk add --no-cache build-base automake autoconf
WORKDIR /home/optima
COPY . .
RUN autoreconf --install
RUN ./configure
RUN make


FROM alpine
COPY --from=build /home/optima/FuncA /usr/local/bin/FuncA
ENTRYPOINT ["/usr/local/bin/FuncA"]
