defmodule NasaApodParser do
  @moduledoc """
  `NasaApodParser` - simple nasa \"a picture of the day\" parser.
  It will parse nasa apod picture and download in expected directory
  """
  use Application

  @type api_response :: %{String.t => String.t}

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end


  @spec main([binary]) :: :ok
  def main(data) do
    parser_options = [
      strict: [help: :boolean, hd: :boolean, dir: :string],
      aliases: [h: :help, d: :dir]
    ]
    options = OptionParser.parse(data, parser_options)

    case options do
      {[hd: true], ["get-url"], _} -> get_hdurl() |> IO.puts
      {[help: true], ["get-url"], _} -> help_get_url() |> IO.puts
      {_, ["get-url"], _} -> get_url() |> IO.puts


      {[hd: true, dir: dir], ["download"], _} -> download(get_hdurl(), Path.expand(dir))
      {[hd: true], ["download"], _} -> download(get_hdurl(), get_downloads_path())
      {[dir: dir], ["download"], _} -> download(get_url(), Path.expand(dir))
      {[help: true], ["download"], _} -> help_download() |> IO.puts
      {_, ["download"], _} -> download(get_url(), get_downloads_path())


      {[help: true], _, _} -> help() |> IO.puts
      _ -> help() |> IO.puts
    end
  end

  @spec download(String.t, String.t) :: :ok
  def download(url, dir) do
    raw_image = HTTPoison.get!(url).body

    filename = Enum.at(String.split(url, "/"), -1)
    full_path = Path.join(dir, filename)

    File.write!(full_path, raw_image, [:raw])
    :ok
  end

  @spec get_url :: String.t
  def get_url do
    get_api_response()["url"]
  end

  @spec get_hdurl :: String.t
  def get_hdurl do
    get_api_response()["hdurl"]
  end

  @spec get_api_response :: api_response()
  def get_api_response do
    response = get_api_url() |> HTTPoison.get!()
    Jason.decode!(response.body)
  end

  @spec get_downloads_path :: String.t
  def get_downloads_path do
    home = System.fetch_env!("HOME")
    russian_downloads = Path.join(home, "Загрузки")

    if File.exists?(russian_downloads) do
      russian_downloads
    else
      Path.join(home, "Downloads")
    end
  end

  @spec get_api_url :: String.t
  def get_api_url do
    "https://api.nasa.gov/planetary/apod?api_key=" <> System.get_env("NASA_KEY", "DEMO_KEY")
  end

  @spec help :: String.t
  defp help do
    """
    Usage: nasa_apod [OPTIONS] command [ARGS]...

      NASA \"A picture of the day\" downloader and parser.

    Options:
      -h, --help  Show this message

    Commands:
      download  Download apod to expected directory
      get-url   Get url of current apod
    """
  end

  @spec help_get_url :: String.t
  defp help_get_url do
    """
    Usage: nasa_apod [OPTIONS] get-url

      Get url of current \"a picture of the day\".

    Options:
      -h, --help  Show this message
      --hd        Get HD url
    """
  end

  @spec help_download :: String.t
  defp help_download do
    """
    Usage: nasa_apod [OPTIONS] download

      Download current \"a picture of the day\".

    Options:
      -d, --dir=PATH  Directory to save image [DEFAULT: <YOUR DOWNLOADS DIR>]
      -h, --help      Show this message
      --hd            Download HD image
    """
  end
end
