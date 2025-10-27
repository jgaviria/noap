if Code.ensure_loaded?(Finch) do
  defmodule Noap.HTTP.Finch do
    @behaviour Noap.HTTP
    require Logger

    @impl Noap.HTTP
    def post(url, headers, soap_request, options) do
      do_post(url, headers, soap_request, options, true)
    end

    defp do_post(url, headers, soap_request, options, retry?) do
      # Extract the finch module from options, default to MyFinch for backwards compatibility
      finch_module = Keyword.get(options, :finch, MyFinch)

      # Remove the finch option before passing to Finch.build to avoid warnings
      finch_options = Keyword.delete(options, :finch)

      case Finch.build(:post, url, headers, soap_request, finch_options) |> Finch.request(finch_module) do
        {:ok, %Finch.Response{status: status, body: soap_response}} ->
          {:ok, status, soap_response}

        {:error, error} ->
          case {retry?, error} do
            {true, %Mint.TransportError{reason: :closed}} ->
              Logger.info("Retrying NOAP post due to :closed error")
              do_post(url, headers, soap_request, options, false)

            {_, error} ->
              {:error, inspect(error)}
          end
      end
    end
  end
end
