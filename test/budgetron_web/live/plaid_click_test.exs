defmodule BudgetronWeb.PlaidLiveClickTest do
  use BudgetronWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  defp stub_plaid(body) do
    {:ok, listen} = :gen_tcp.listen(0, [:binary, packet: :raw, active: false, ip: {127, 0, 0, 1}])
    {:ok, port} = :inet.port(listen)
    parent = self()

    spawn_link(fn ->
      {:ok, sock} = :gen_tcp.accept(listen)
      {:ok, req} = :gen_tcp.recv(sock, 0, 5000)
      send(parent, {:got_request, req})

      response =
        "HTTP/1.1 200 OK\r\ncontent-type: application/json\r\ncontent-length: #{byte_size(body)}\r\nconnection: close\r\n\r\n" <>
          body

      :gen_tcp.send(sock, response)
      :gen_tcp.close(sock)
    end)

    Application.put_env(:budgetron, :plaid,
      client_id: "x",
      secret: "y",
      env: "sandbox",
      base_url: "http://127.0.0.1:#{port}"
    )

    on_exit(fn -> Application.delete_env(:budgetron, :plaid) end)
  end

  test "connect pushes link token event", %{conn: conn} do
    stub_plaid(
      ~s|{"link_token": "link-test-123", "expiration": "2030-01-01T00:00:00Z", "request_id": "r1"}|
    )

    {:ok, view, _html} = live(conn, ~p"/plaid")
    render_click(view, "connect", %{})

    assert_push_event(view, "plaid:link_token", %{link_token: "link-test-123"})
  end
end
