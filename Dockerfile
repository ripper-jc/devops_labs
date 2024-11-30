FROM alpine AS build
RUN apk add --no-cache automake autoconf build-base
WORKDIR /home/optima
COPY . .
RUN ./configure
RUN make


FROM alpine
COPY --from=build /home/optima/FuncA /usr/local/bin/FuncA
ENTRYPOINT ["/usr/local/bin/FuncA"]
