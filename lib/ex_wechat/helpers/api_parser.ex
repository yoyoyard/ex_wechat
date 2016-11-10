defmodule ExWechat.Helpers.ApiParser do

  @doc """
    parse data from api definition file with parttern match
  """
  def do_parse_api_data(data), do: _do_parse_api_data(%{}, [], data)

  defp _do_parse_api_data(temp, result, endpoint \\ nil, lines)
  defp _do_parse_api_data(_temp, result, _, []), do: result
  defp _do_parse_api_data(temp, result, endpoint, [ "//" <> _ | tail ]), do: _do_parse_api_data(temp, result, endpoint, tail)
  defp _do_parse_api_data(temp, result, endpoint, [ "# " <> rest | tail ]), do: temp |> save_map(:doc, rest) |> _do_parse_api_data(result, endpoint, tail)
  defp _do_parse_api_data(temp, result, nil, [ "@endpoint " <> rest | tail ]), do: temp |> save_map(:endpoint, rest) |> _do_parse_api_data(result, rest |> String.trim, tail)
  defp _do_parse_api_data(temp, result, endpoint, [ "@endpoint " <> rest | tail ]), do: temp |> save_map(:endpoint, rest) |> _do_parse_api_data(result, endpoint, tail)
  defp _do_parse_api_data(temp, result, endpoint, [ "function: " <> rest | tail ]), do: temp |> save_map(:function, rest) |> _do_parse_api_data(result, endpoint, tail)
  defp _do_parse_api_data(temp, result, endpoint, [ "path: " <> rest | tail ]), do: temp |> save_map(:path, rest) |> _do_parse_api_data(result, endpoint, tail)
  defp _do_parse_api_data(temp, result, endpoint, [ "http: " <> rest | tail ]), do: temp |> save_map(:http, rest) |> _do_parse_api_data(result, endpoint, tail)
  defp _do_parse_api_data(%{endpoint: _} = temp, result, endpoint, [ "params:" <> rest | tail ]) do
    temp = temp |> save_map(:params, rest)
    _do_parse_api_data(%{}, result ++ [temp], endpoint, tail)
  end
  defp _do_parse_api_data(temp, result, endpoint, [ "params:" <> rest | tail ]) do
    temp = temp |> save_map(:endpoint, endpoint) |> save_map(:params, rest)
    _do_parse_api_data(%{}, result ++ [temp], endpoint, tail)
  end

  defp save_map(map, key, value)
  defp save_map(map, :function, value), do: map |> Map.put(:function, value |> String.trim |> String.to_atom)
  defp save_map(map, :http, value),     do: map |> Map.put(:http,     value |> String.trim |> String.to_atom)
  defp save_map(map, :doc, value),      do: map |> Map.put(:doc,      Map.get(map, :doc, "") <> (value |> String.trim))
  defp save_map(map, :endpoint, value), do: map |> Map.put(:endpoint, value |> String.trim)
  defp save_map(map, :params, value),   do: map |> Map.put(:params,   value |> String.trim)
  defp save_map(map, :path, value),     do: map |> Map.put(:path,     value |> String.trim)
end
