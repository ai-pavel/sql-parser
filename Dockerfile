# ---- Build stage ----------------------------------------------------
FROM ocaml/opam:debian-12-ocaml-5.1 AS build

WORKDIR /src
COPY --chown=opam:opam . .

# The binaries only need dune plus the compiler stdlib + unix, so no
# other opam dependencies are required.
RUN opam install -y dune \
 && opam exec -- dune build --profile release bin/main.exe bin/server.exe

# ---- Runtime stage --------------------------------------------------
FROM debian:stable-slim

WORKDIR /app
COPY --from=build /src/_build/default/bin/server.exe /usr/local/bin/sql-parser-server
COPY --from=build /src/_build/default/bin/main.exe /usr/local/bin/sql-parser-repl

EXPOSE 8080

CMD ["sql-parser-server"]
