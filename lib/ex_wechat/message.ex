defmodule ExWechat.Message do

  @text         "text.eex"
  @voice        "voice.eex"
  @video        "video.eex"
  @shortvideo   "shortvideo.eex"
  @image        "image.eex"
  @news         "news.exx"

  def build_message(msg) do
    render_message(msg)
  end

  def parser_message(xml_msg) do
    [{"xml", [], attrs}] = Floki.find(xml_msg, "xml")
    for {key, _, [value]} <- attrs, into: %{} do
      {String.to_atom(key), value}
    end
  end

  defp render_message(msg = %{type: "text"}),       do: render(@text,       msg)
  defp render_message(msg = %{type: "video"}),      do: render(@video,      msg)
  defp render_message(msg = %{type: "shortvideo"}), do: render(@shortvideo, msg)
  defp render_message(msg = %{type: "voice"}),      do: render(@voice,      msg)
  defp render_message(msg = %{type: "image"}),      do: render(@image,      msg)
  defp render_message(msg = %{type: "news"}),       do: render(@news,       msg)

  defp render(file, msg) do
    {:ok, template} = File.read(Path.join([__DIR__, "templates", file]))
    EEx.eval_string template, Enum.map(msg, fn ({key, value}) -> {key, value} end)
  end
end