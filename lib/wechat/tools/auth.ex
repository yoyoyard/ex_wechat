defmodule Wechat.Auth do

  alias Wechat.Http

  @api_endpoint "https://api.weixin.qq.com"

  @api_path "/sns/oauth2/access_token"
  @userinfo_path "/sns/userinfo"

  def info(code, options) do
    callback = &Http.parse_wechat_site/1

    # fetch for openid
    result = Http.get(request_auth_opts(code, options), callback)

    case result do
      %{errcode: _code} ->
        {:error, "bad code or code has been used"}
      _ ->
        if options[:scope] == "snsapi_base" do
          {:ok, result}
        else
          {:ok, Http.get(request_info_opts(result), callback)}
        end
    end
  end

  defp request_auth_opts(code, options) do
    api = options[:api] || Wechat.Api
    appid = apply(api, :appid, [])
    secret = apply(api, :secret, [])

    [url: api_url(), params: [appid: appid, secret: secret,
      code: code, grant_type: "authorization_code"]]
  end

  defp request_info_opts(result) do
    [ url: userinfo_url(),
      params: [access_token: result.access_token, openid: result.openid,
        lang: "zh_CN"]]
  end

  defp api_url do
    @api_endpoint <> @api_path
  end

  defp userinfo_url() do
    @api_endpoint <> @userinfo_path
  end
end
