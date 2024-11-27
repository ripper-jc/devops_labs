FROM alpine
WORKDIR /home/optima
COPY ./FuncA .
RUN apk add libstdc++
RUN apk add libc6-compat
ENTRYPOINT ["./FuncA"]
