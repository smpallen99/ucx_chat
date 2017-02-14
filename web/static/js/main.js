$(document).ready(function() {
  $('body').on('click', 'a.toggle-favorite', function() {
    ucxchat.chan.push("room:favorite", {client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
      })
    // {:ok, %{messages_html: messages_html, side_nav_html: side_nav_html}}
    return false
  })
})
