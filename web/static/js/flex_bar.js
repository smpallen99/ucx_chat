$(document).ready(function() {
  $('body').on('click', '.tab-button[title="Info"]', function() {
    console.log('Info button clicked...')
    if ($('section.flex-tab').parent().hasClass('opened')) {
      close_flex_tab()
    } else {
      roomchan.push("flex_bar:click:Info", {templ: "channel_settings.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
        .receive("ok", resp => {
          console.log('info response', resp)
          $('section.flex-tab').html(resp.html).parent().addClass('opened')
      })
    }
  })
  $('body').on('click', '.tab-button[title="Search"]', function() {
    console.log('Search button clicked...')
  })
  $('body').on('click', '.tab-button[title="Members List"]', function() {
    console.log('Members List button clicked...')
    if ($('section.flex-tab').parent().hasClass('opened')) {
      close_flex_tab()
    } else {
      roomchan.push("flex_bar:click:Members List", {templ: "clients_list.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
        .receive("ok", resp => {
          $('section.flex-tab').html(resp.html).parent().addClass('opened')
      })
    }
  })
  $('body').on('click', '.tab-button[title="User Info"]', function() {
    console.log('User Info button clicked...')
  })
  $('body').on('click', '.tab-button[title="Notifications"]', function() {
    console.log('Notifications button clicked...')
  })
  $('body').on('click', '.tab-button[title="Mentions"]', function() {
    console.log('Mentions button clicked...')
  })
  $('body').on('click', 'button.user.user-card-message', function() {
    let username = $(this).attr('data-username')
    console.log('user-card-message button clicked...', username)
    roomchan.push("flex_bar:click:Members List", {nickname: username, templ: "clients_list.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        $('section.flex-tab').html(resp.html).parent().addClass('opened')
    })
  })
  $('body').on('click', '.flex-tab-container .user-view nav .button.back', function() {
    $('.flex-tab-container .user-view').addClass('animated-hidden')
  })
  $('body').on('click', 'li.user-card-room button', function() {
    let nickname = $(this).attr('data-username')
    console.log('view user button clicked', nickname)
    roomchan.push("flex_bar:click:Members List", {nickname: nickname, templ: "clients_list.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        console.log('resp', resp)
        $('section.flex-tab').html(resp.html).parent()
        open_flex_tab()
    })

  })
})

function close_flex_tab() {
  if ($('section.flex-tab').parent().hasClass('opened')) {
    $('section.flex-tab').html('').parent().removeClass('opened')
  }
}
function open_flex_tab() {
  if (!$('section.flex-tab').parent().hasClass('opened')) {
    $('section.flex-tab').parent().addClass('opened')
  }
}
