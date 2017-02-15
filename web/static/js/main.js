
import * as flex_bar from './flex_bar'

$(document).ready(function() {
  $('body').on('click', 'a.toggle-favorite', function() {
    roomchan.push("room:favorite", {client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
      })
    // {:ok, %{messages_html: messages_html, side_nav_html: side_nav_html}}
    return false
  })
  $('body').on('click', '.button.pvt-msg', function() {
    let nickname = $(this).parent().attr('data-username')
    console.log('pvt-msg button clicked...', nickname)
    roomchan.push("room:add-direct", {nickname: nickname, client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
        // flex_bar.close_flex_tab()
        if ($('section.flex-tab').parent().hasClass('opened')) {
          $('section.flex-tab').html('').parent().removeClass('opened')
        }
    })
  })
})
