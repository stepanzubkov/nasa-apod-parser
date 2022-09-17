# NasaApodParser

NASA Apod parser & downloader built with Elixir end compiled with escript.

## Installation

### Linux (Debian-based)

TODO: Add deb package to releases

### Advanced build (or Windows)

Install Erlang/OTP and Elixir

Clone repo

```
git clone https://github.com/Stepan-Zubkov/nasa-apod-parser.git
```

Go to project dir

```
cd nasa-apod-parser
```

Get dependencies

```
mix deps.get
```

Build package with escript

```
mix escript.build
```

Done! Run executable file

```
./nasa_apod_parser --help
```

or

```
escript nasa_apod_parser --help
```
